# web_server_with_health_check

## Install Git

### For Linux Debian and Ubuntu

```
# Update packages and Upgrade system
sudo apt-get update -y

#Installing Git..
sudo apt-get install git -y
```

### For Linux Redhat
```
yum update
yum install git 
``` 

### For Powershell
Get-ExecutionPolicy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
Install-Module posh-git -Scope CurrentUser -Force
Import-Module posh-git
Add-PoshGitToProfile -AllHosts

## Prequisite
You need to have git installed on your PC, preferbably version 2.17.1
If you use Powershell, this works best on version 5.1.19041.1320
If you use Linux Bash, it works best on Ubuntu 18.04.5 LTS

## Clone repo

Please clone repo by this command:

```
git clone https://github.com/tuanvu0606/web_server_with_health_check.git
```

## Set up AWS credentials

Set up your AWS credentials by the following commands, use the commands base on your system

### Linux either Redhat or Debian distributions (Bash)

```bash
export AWS_SECRET_DEFAULT_KEY_ID=""
export AWS_SECRET_DEFAULT_ACCESS_KEY=""
export AWS_DEFAULT_REGION=""
```

if you have any errors, try to add lines to the files
```
touch ~/.aws/credentials
> ~/.aws/credentials
cat <<EOT >> ~/.aws/credentials
[default]
aws_access_key_id="Your Key ID"
aws_secret_access_key="Your Key""
EOT

touch  ~/.aws/config
>  ~/.aws/config
cat <<EOT >> ~/.aws/config
[default]
region="Your Region"
output="Your Format"
EOT
```

### Windows (Powershell)
```
$Env:AWS_ACCESS_KEY_ID="Your Key ID"
$Env:AWS_SECRET_ACCESS_KEY="Your Key"
$Env:AWS_DEFAULT_REGION="Region"
```

or try this if issue happens

```
$AwsCredentials = @'
[default]
aws_access_key_id="Your Key ID" 
aws_secret_access_key="Your Key"
'@

$AwsConfig = @'
[default]
region="Your Region"
output="Your Format"
'@

New-Item -Path "$env:USERPROFILE\" -Name ".aws" -ItemType "directory"
New-Item -Path "$env:USERPROFILE\.aws\" -Name "credentials" -ItemType "file"
New-Item -Path "$env:USERPROFILE\.aws\" -Name "config" -ItemType "file"
$AwsCredentials -f 'string' | Out-File $env:USERPROFILE\.aws\credentials
$AwsConfig -f 'string' | Out-File $env:USERPROFILE\.aws\config
```

## Usage

Run the commands below to create or destroy the application stack, if you create it, it will automatically do health check

### Linux (Bash)

#### create

```
chmod 0770 ./main.sh
./main.sh create
```

#### destroy
```
chmod 0770 ./main.sh
./main.sh destroy
```

### Windows (Powershell)

Run the commands below to create or destroy the application stack, if you create it, it will automatically do health check
#### create

```
.\main.ps1 -command create
```

#### destroy
```
.\main.ps1 -command destroy
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
