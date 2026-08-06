
# This Terraform configuration is intentionally misconfigured to trigger CKV_AWS_79.
# It is used for testing the XSUP-71494 fix — verifying that the evidence highlights
# the `http_tokens = "optional"` line (the actual misconfiguration) rather than the
# closing `}` of the metadata_options block.
#
# CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
# Fix: change http_tokens from "optional" to "required".

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "vulnerable_imdsv1" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t3.micro"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional" # CKV_AWS_79: This should be "required" to enforce IMDSv2
  }

  tags = {
    Name        = "xsup-71494-test-instance"
    Purpose     = "CKV_AWS_79 evidence line-number validation"
    Environment = "test"
  }
}
