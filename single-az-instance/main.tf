provider "aws" {
  version = "~> 3.0"
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "terraform-state-20230927"
    key    = "single-az-instance"
    region = "ap-southeast-1"
  }
}