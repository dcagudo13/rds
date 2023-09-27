terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-20230927"
    key    = "test-module"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region     = "ap-southeast-1"
}

locals {
  prefix = "demo-${var.env}"
}

resource "aws_s3_bucket" "demo" {
  bucket = "${local.prefix}-s3-bucket-454"

  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "versioning_demo" {
  bucket = aws_s3_bucket.demo.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
