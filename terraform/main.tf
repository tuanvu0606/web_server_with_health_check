terraform {
  backend "s3" {
    # Replace this wicd -th your bucket name!
    bucket         = "challenge-terraform-state-s3-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "challenge-terraform-state-dynamodb"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "challenge_web_server" {
  source = "./modules/services/challenge-web-server"

  key_name = "challenge_tls_key"
}