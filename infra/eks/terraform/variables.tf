variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-workshop"
}

variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
  default     = "1.29"
}

variable "ami_release_version" {
  description = "Default EKS AMI release version for node groups"
  type        = string
  default     = "1.29.0-20240129"
}

variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "10.42.0.0/16"
}

variable "vault_client_id" {
  description = "Vault client ID"
  type        = string
  default     = ""
}

variable "vault_client_secret" {
  description = "Vault client secret"
  type        = string
  default     = ""
}

variable "vault_app" {
  description = "Vault app name"
  type        = string
  default     = "awscreds"
}