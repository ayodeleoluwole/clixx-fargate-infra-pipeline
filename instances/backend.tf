terraform {
  backend "s3" {
    bucket  = "mystatefile-clixxretail"
    key     = "base-infrastructure/terraform.tfstate"
    region  = "us-east-2"
  }
}