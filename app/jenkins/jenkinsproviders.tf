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

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
  }

  required_version = ">= 1.4.2"
}

provider "aws" {
  region = "us-east-1"
  access_key = data.hcp_vault_secrets_secret.aws_access_key.secret_value
  secret_key = data.hcp_vault_secrets_secret.aws_secret.secret_value
  default_tags {
    tags = local.tags
  }
}

provider "hcp" {
  client_id = var.vault_client_id
  client_secret = var.vault_client_secret
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_efs_file_system" "by_id" {
  file_system_id = "${var.cluster_name}-efs"
}

data "hcp_vault_secrets_secret" "aws_access_key" {
  app_name    = var.vault_app
  secret_name = "aws_access_key"
}

data "hcp_vault_secrets_secret" "aws_secret" {
  app_name    = var.vault_app
  secret_name = "aws_secret_access_key"
}



locals {
  tags = {
    created-by = "eks-workshop-v2"
    env        = var.cluster_name
  }
}
