#!/bin/bash

declare_variable(){
    
    # declare all variables

    export TF_VAR_challenge_terraform_state_s3_bucket_name=challenge-terraform-state-s3-bucket
    export TF_VAR_challenge_terraform_state_s3_bucket_region=ap-southeast-1
    export TF_VAR_challenge_terraform_state_dynamo_db_table_name=challenge-terraform-state-dynamodb
    export TF_VAR_challenge_terraform_state_dynamo_db_table_billing_mode=PAY_PER_REQUEST
    export INSTANCE_IP_ADDRESS=""
    export INSTANCE_USER=""
}

install_aws_cli(){

    # Check if AWS Cli is installed, if yes then move forward, ignore this

    if [ ! $(which aws) ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        # clean up
        rm -rf ./awscliv2.zip
        rm -rf ./aws
    else
        echo "aws cli is already installed"
    fi
}
# install terraform

install_terraform(){

    # Check if Terraform is installed, if yes then move forward, ignore this

    if [ ! $(which terraform) ]; then
        # clean previous terraform version
        rm -rf /usr/local/bin/terraform

        wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
        unzip terraform_1.0.11_linux_amd64.zip
        
        chmod +x terraform
        
        sudo mv terraform /usr/local/bin/
        terraform --version

        # clean up
        rm -rf ./terraform
        rm -rf ./terraform_1.0.11_linux_amd64.zip
    else
        echo "Terraform is already installed"
    fi
}

create_s3_bucket_for_terraform_state(){
    # create s3 bucket for terraform state
    aws \
        s3api \
        create-bucket \
            --bucket "${TF_VAR_challenge_terraform_state_s3_bucket_name}" \
            --region "${TF_VAR_challenge_terraform_state_s3_bucket_region}" \
            --create-bucket-configuration \
                LocationConstraint="${TF_VAR_challenge_terraform_state_s3_bucket_region}"

}

create_dynamo_db_for_terraform_state_lock(){

    # create dynamo db for terraform state locks

    aws dynamodb create-table \
    --table-name "${TF_VAR_challenge_terraform_state_dynamo_db_table_name}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode "${TF_VAR_challenge_terraform_state_dynamo_db_table_billing_mode}"
}
# ---------------------------------------------- Terraform ----------------------------------------------------

create_terraform_ec2_server(){

    # automatically provision the server by Terraform

    cd ./terraform
    terraform init
    terraform apply -auto-approve
    mkdir ~/.ssh
    touch ~/.ssh/challenge-ec2-private-key.pem
    > ~/.ssh/challenge-ec2-private-key.pem
    terraform output tls_private_key_pem_content > ~/.ssh/challenge-ec2-private-key.pem
    chmod 0600 ~/.ssh/challenge-ec2-private-key.pem
    cd ..
}

remove_terraform_ec2_server(){

    # automatically removes the server by Terraform

    cd ./terraform
    terraform destroy -auto-approve
    cd ..
}



get_ec2_instance_ip_address (){

    # query ec2 server public IP address

    cd ./terraform
    INSTANCE_IP_ADDRESS=$(terraform output instance_ip_addr | sed 's/"//g' )
    USER=ubuntu
    cd ..
}

create_apache_web_server (){

    # Install apache server and fix the content

    get_ec2_instance_ip_address

    ssh \
        -i "~/.ssh/challenge-ec2-private-key.pem" \
        ${USER}@${INSTANCE_IP_ADDRESS} \
        -o "StrictHostKeyChecking no" \
        sudo apt-get update -y && \
        sudo apt-get install -y apache2 && \
        sudo systemctl start apache2.service && \
        sudo systemctl enable apache2.service && \
        echo "Hello World"  | sudo tee -a /var/www/html/index.html
        
}

create_stack(){
    declare_variable

    install_aws_cli

    install_terraform

    create_s3_bucket_for_terraform_state

    create_dynamo_db_for_terraform_state_lock

    create_terraform_ec2_server

    create_apache_web_server

    source ./health_check.sh

    get_ec2_instance_ip_address

    while true
    do  
        health_check ${INSTANCE_IP_ADDRESS}
        echo "Press [CTRL+C] to stop.."
        sleep 1
    done

}

destroy_stack(){
    declare_variable

    remove_terraform_ec2_server

    # aws \
    #     s3api \
    #     delete-bucket \
    #         --bucket "${TF_VAR_challenge_terraform_state_s3_bucket_name}" \
    #         --region "${TF_VAR_challenge_terraform_state_s3_bucket_region}"

    # aws dynamodb delete-table \
    #     --table-name "${TF_VAR_challenge_terraform_state_dynamo_db_table_name}" 
}

main(){
    if [ "$1" = "create" ]; then
        echo "create."
        create_stack
    elif [ "$1" = "destroy" ]; then
        echo "destroy"
        destroy_stack
    else 
        echo 'Please choose to "create" or "destroy" the stack'
    fi
}

main $1