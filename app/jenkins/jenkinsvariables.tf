variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-workshop"
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