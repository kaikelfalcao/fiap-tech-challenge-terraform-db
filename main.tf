provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "fiap-tech-challenge-terraform-db"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  # Mesmo bucket usado por todos os repos — derivado do account ID automaticamente.
  tfstate_bucket = "fiap-tc-tfstate-${data.aws_caller_identity.current.account_id}"
}

data "terraform_remote_state" "k8s" {
  backend = "s3"
  config = {
    bucket = local.tfstate_bucket
    key    = "k8s-infra/terraform.tfstate"
    region = var.region
  }
}
