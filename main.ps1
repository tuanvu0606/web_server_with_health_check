param (    
    # create or destroy
    [string]$command = 'nope'
)
# install aws cli

Function declare_variable{
    $Env:TF_VAR_challenge_terraform_state_s3_bucket_name = "challenge-terraform-state-s3-bucket"
    $Env:TF_VAR_challenge_terraform_state_s3_bucket_region = "ap-southeast-1"
    $Env:TF_VAR_challenge_terraform_state_dynamo_db_table_name = "challenge-terraform-state-dynamodb"
    $Env:TF_VAR_challenge_terraform_state_dynamo_db_table_billing_mode = "PAY_PER_REQUEST"
    $Env:INSTANCE_IP_ADDRESS = ""
    $Env:INSTANCE_USER = ""
}

Function install_aws_cli{

    # Check if AWS Cli is installed, if yes then move forward

    try {
        Get-Command aws | Select-Object -ExpandProperty Definition
        Write-Output "aws cli is already installed"
        aws --version
    }
    catch {
        Write-Output "Installing aws cli now"
        $dlurl = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
        $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
        Invoke-WebRequest $dlurl -OutFile $installerPath
        Start-Process -FilePath msiexec -Args "/i $installerPath /passive" -Verb RunAs -Wait
        Remove-Item $installerPath
        $env:Path += ";C:\Program Files\Amazon\AWSCLI\bin"
    }
}

# install Terraform powershell
Function install_terraform{

    # Check if Terraform is installed, if yes then move forward

    try {
        Get-Command terraform | Select-Object -ExpandProperty Definition
        Write-Output "terraform is already installed"
        terraform --version
    }
    catch {
        Write-Output "Installing terraform now"
        $dlurl = "https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_windows_amd64.zip"
        Invoke-WebRequest $dlurl -OutFile "C:\terraform_1.0.11_windows_amd64.zip"
        mkdir "C:\terraform"
        Expand-Archive -LiteralPath "C:\terraform_1.0.11_windows_amd64.zip" -DestinationPath "C:\terraform"
        $env:Path += ";C:\terraform"
    }
}

Function create_s3_bucket_for_terraform_state{
    # create s3 bucket for terraform state
    aws `
        s3api `
        create-bucket `
            --bucket $Env:TF_VAR_challenge_terraform_state_s3_bucket_name `
            --region $Env:TF_VAR_challenge_terraform_state_s3_bucket_region `
            --create-bucket-configuration `
                LocationConstraint=$Env:TF_VAR_challenge_terraform_state_s3_bucket_region

}

Function create_dynamo_db_for_terraform_state_lock{
    # create s3 bucket for terraform state
    aws dynamodb create-table `
    --table-name $Env:TF_VAR_challenge_terraform_state_dynamo_db_table_name `
    --attribute-definitions AttributeName=LockID,AttributeType=S `
    --key-schema AttributeName=LockID,KeyType=HASH `
    --billing-mode $Env:TF_VAR_challenge_terraform_state_dynamo_db_table_billing_mode

}

# ---------------------------------------------- Terraform ----------------------------------------------------

Function create_terraform_ec2_server{

    # automatically provision the server by Terraform

    cd ./terraform
    terraform init
    terraform apply -auto-approve

    if (-Not (Test-Path -Path $env:USERPROFILE/.ssh -PathType Container)) {
        mkdir $env:USERPROFILE/.ssh
    }

    if (-Not (Test-Path -Path $env:USERPROFILE/.ssh/challenge-ec2-private-key.pem -PathType Leaf)) {
        New-Item -Path $env:USERPROFILE/.ssh -Name "challenge-ec2-private-key.pem" -ItemType "file"
    }
       Clear-Content "$env:USERPROFILE/.ssh/challenge-ec2-private-key.pem"
    terraform output tls_private_key_pem_content | Out-File $env:USERPROFILE/.ssh/challenge-ec2-private-key.pem
    
    cd ..
}

Function remove_terraform_ec2_server{

    # automatically removes the server by Terraform

    cd ./terraform
    terraform destroy -auto-approve
    cd ..
}

Function get_ec2_instance_ip_address{

    # query ec2 server public IP address

    cd ./terraform
    $Env:INSTANCE_IP_ADDRESS=(terraform output instance_ip_addr)
    $Env:INSTANCE_IP_ADDRESS=$Env:INSTANCE_IP_ADDRESS.Trim('"')  
    $Env:USER="ubuntu"
    cd ..
}

Function create_apache_web_server {

    # Install apache server and fix the content

    get_ec2_instance_ip_address

    $path = "$env:USERPROFILE\.ssh\challenge-ec2-private-key.pem"

    (Get-Content $path -Raw).Replace("`r`n","`n") | Set-Content $path -Force

    ssh -i "$env:USERPROFILE\.ssh\challenge-ec2-private-key.pem" -o "StrictHostKeyChecking no"  ubuntu@$Env:INSTANCE_IP_ADDRESS "    
        sudo apt-get update -y && \
        sudo apt-get install -y apache2  && \
        sudo systemctl start apache2.service && \
        sudo systemctl enable apache2.service && \
        echo 'Hello World'  | sudo tee -a /var/www/html/index.html
    "
}

Function do_health_check(){

    get_ec2_instance_ip_address

    .\health_check.ps1 -server_address $Env:INSTANCE_IP_ADDRESS
}

Function remove_terraform_ec2_server{
    cd ./terraform
    terraform destroy -auto-approve
    cd ..
}

Function create_stack(){

    create_s3_bucket_for_terraform_state

    create_dynamo_db_for_terraform_state_lock

    create_terraform_ec2_server

    create_apache_web_server

    get_ec2_instance_ip_address

    while ([Console]::ReadKey($true)) {
        Write-Output "Press your break key to stop.."
        do_health_check
        Start-Sleep -Seconds 1  
    } 

    
}

Function destroy_stack {
   remove_terraform_ec2_server

    aws `
        s3api `
        delete-bucket `
            --bucket $Env:TF_VAR_challenge_terraform_state_s3_bucket_name `
            --region $Env:TF_VAR_challenge_terraform_state_s3_bucket_region

    aws dynamodb delete-table `
        --table-name $Env:TF_VAR_challenge_terraform_state_dynamo_db_table_name 
}

declare_variable

install_aws_cli

install_terraform


if ($command -eq "create") {
    Write-Output "create"
    create_stack
} elseif ($command -eq "destroy") {
    Write-Output "destroy"
    destroy_stack
} else {
    Write-Output "Please choose to destroy or create"
}