terraform {
  backend "s3" {
    bucket         = "devops-state-504508177008"
    key            = "labs/lab3-min-ec2-docker/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "DevOps-lock"
    encrypt        = true
  }
}
