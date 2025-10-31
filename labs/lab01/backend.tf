terraform {
  backend "s3" {
    bucket         = "devops-state-504508177008"
    key            = "labs/lab1-vpc-ec2/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "DevOps-lock"
    encrypt        = true
  }
}