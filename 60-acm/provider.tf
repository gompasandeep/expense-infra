terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }

  backend "s3" {
    bucket = "82s-remote-state-dev-sandeep"
    key    = "expense-dev-gompa-eks-acm" # you should have unique keys with in the bucket, same key should not be used in other repos or tf projects
    region = "us-east-1"
    dynamodb_table = "82s-remote-state-dev-sandeep"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}