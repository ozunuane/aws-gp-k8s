# Development Environment - Backend Configuration

terraform {
  backend "s3" {
    bucket  = "terraform-state-dev-aws-gp-k8s-REPLACE-WITH-ACCOUNT-ID"
    key     = "dev/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
    # Optional: Use KMS for additional security
    # kms_key_id     = "alias/terraform-state-key"
  }
} 