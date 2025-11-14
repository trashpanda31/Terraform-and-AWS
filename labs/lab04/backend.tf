terraform {
  backend "s3" {
    bucket         = "devops-state-504508177008"
    key            = "lab04/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "DevOps-lock"
    encrypt        = true
  }
}
