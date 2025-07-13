# IAM Module - Variables

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# User Variables
variable "devops_users" {
  description = "Map of DevOps users"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "developer_users" {
  description = "Map of Developer users"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "qa_users" {
  description = "Map of QA users"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "readonly_users" {
  description = "Map of Read-only users"
  type = map(object({
    name = string
  }))
  default = {}
}

# Access Key Variables
variable "create_access_keys" {
  description = "Create access keys for users (not recommended for production)"
  type        = bool
  default     = false
}

# GitHub OIDC Variables
variable "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN for CI/CD"
  type        = string
  default     = null
}

variable "github_repository_subjects" {
  description = "List of GitHub repository subjects for OIDC"
  type        = list(string)
  default     = []
}

# Password Policy Variables
variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length        = number
    require_lowercase     = bool
    require_numbers       = bool
    require_uppercase     = bool
    require_symbols       = bool
    allow_users_to_change = bool
    hard_expiry           = bool
    max_age               = number
    reuse_prevention      = number
  })
  default = {
    minimum_length        = 14
    require_lowercase     = true
    require_numbers       = true
    require_uppercase     = true
    require_symbols       = true
    allow_users_to_change = true
    hard_expiry           = false
    max_age               = 90
    reuse_prevention      = 24
  }
}

# MFA Variables
variable "enforce_mfa" {
  description = "Enforce MFA for all users"
  type        = bool
  default     = true
} 