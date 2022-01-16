# web_server_with_health_check

# Foobar

Foobar is a Python library for dealing with word pluralization.

## Installation

### Linux ()

First, set up your AWS credentials by the following commands

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
aws_access_key_id="Your Key"
aws_secret_access_key="A1vaPMHrz1b6TYorOTVeMR137pIFPo9r3mI0Lgsy"
EOT

touch  ~/.aws/config
>  ~/.aws/config
cat <<EOT >> ~/.aws/config
[default]
region="Your Region"
output="Your Format"
EOT
```

### Powershell
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

$AwsCredentials -f 'string' | Out-File $env:USERPROFILE\.aws\credentials
$AwsConfig -f 'string' | Out-File $env:USERPROFILE\.aws\config
```

## Usage

```python
import foobar

# returns 'words'
foobar.pluralize('word')

# returns 'geese'
foobar.pluralize('goose')

# returns 'phenomenon'
foobar.singularize('phenomena')
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
