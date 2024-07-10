provider "aws" {
  region = "us-east-1"
  access_key = data.hcp_vault_secrets_secret.aws_access_key.secret_value
  secret_key = data.hcp_vault_secrets_secret.aws_secret.secret_value
  default_tags {
    tags = local.tags
  }
}

data "hcp_vault_secrets_secret" "aws_access_key" {
  app_name    = var.vault_app
  secret_name = "aws_access_key"
}

data "hcp_vault_secrets_secret" "aws_secret" {
  app_name    = var.vault_app
  secret_name = "aws_secret_access_key"
}

provider "hcp" {
  client_id = var.vault_client_id
  client_secret = var.vault_client_secret
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.94.1"
    }
  }

  required_version = ">= 1.4.2"
}


