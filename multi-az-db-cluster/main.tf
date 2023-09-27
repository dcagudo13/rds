provider "aws" {
  version = "~> 3.0"
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "terraform-state-20230927"
    key    = "multi-az-db-cluster"
    region = "ap-southeast-1"
  }
}