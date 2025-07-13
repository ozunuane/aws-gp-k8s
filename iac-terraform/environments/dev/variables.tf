# Development Environment - Variables

# Environment-specific features
variable "enable_dedicated_karpenter" {
  description = "Enable dedicated Karpenter module (separate from EKS module)"
  type        = bool
  default     = false
}

# Feature Flags for Resource Deployment
variable "enable_vpc" {
  description = "Enable VPC module deployment"
  type        = bool
  default     = true
}

variable "enable_eks" {
  description = "Enable EKS module deployment"
  type        = bool
  default     = true
}

variable "enable_ingress" {
  description = "Enable NGINX Ingress Controller deployment"
  type        = bool
  default     = true
}

variable "enable_acm" {
  description = "Enable ACM Certificate deployment"
  type        = bool
  default     = true
}

variable "enable_dns_resolver" {
  description = "Enable DNS Resolver deployment"
  type        = bool
  default     = true
}

variable "enable_middleware" {
  description = "Enable Middleware services deployment"
  type        = bool
  default     = true
}

variable "enable_postgres" {
  description = "Enable PostgreSQL RDS deployment"
  type        = bool
  default     = true
}

variable "enable_mysql" {
  description = "Enable MySQL RDS deployment"
  type        = bool
  default     = true
}

variable "enable_iam" {
  description = "Enable IAM module deployment"
  type        = bool
  default     = true
}

# Existing Resource Variables (for when modules are disabled)
variable "existing_vpc_id" {
  description = "Existing VPC ID (used when enable_vpc is false)"
  type        = string
  default     = null
}

variable "existing_private_subnet_ids" {
  description = "Existing private subnet IDs (used when enable_vpc is false)"
  type        = list(string)
  default     = []
}

variable "existing_public_subnet_ids" {
  description = "Existing public subnet IDs (used when enable_vpc is false)"
  type        = list(string)
  default     = []
}

variable "existing_vpc_cidr_block" {
  description = "Existing VPC CIDR block (used when enable_vpc is false)"
  type        = string
  default     = null
}

variable "existing_cluster_endpoint" {
  description = "Existing EKS cluster endpoint (used when enable_eks is false)"
  type        = string
  default     = null
}

variable "existing_cluster_ca_certificate" {
  description = "Existing EKS cluster CA certificate (used when enable_eks is false)"
  type        = string
  default     = null
}

variable "existing_cluster_token" {
  description = "Existing EKS cluster token (used when enable_eks is false)"
  type        = string
  default     = null
}

variable "existing_cluster_security_group_id" {
  description = "Existing EKS cluster security group ID (used when enable_eks is false)"
  type        = string
  default     = null
}

variable "existing_ssl_certificate_arn" {
  description = "Existing SSL certificate ARN (used when enable_acm is false)"
  type        = string
  default     = null
}

variable "existing_external_load_balancer_hostname" {
  description = "Existing external load balancer hostname (used when enable_ingress is false)"
  type        = string
  default     = null
}

variable "existing_external_load_balancer_zone_id" {
  description = "Existing external load balancer zone ID (used when enable_ingress is false)"
  type        = string
  default     = null
}

variable "existing_internal_load_balancer_hostname" {
  description = "Existing internal load balancer hostname (used when enable_ingress is false)"
  type        = string
  default     = null
}

variable "existing_internal_load_balancer_zone_id" {
  description = "Existing internal load balancer zone ID (used when enable_ingress is false)"
  type        = string
  default     = null
}

variable "existing_redis_security_group_id" {
  description = "Existing Redis security group ID (used when enable_middleware is false)"
  type        = string
  default     = null
}

# Middleware passwords
variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  default     = null
  sensitive   = true
}

variable "documentdb_master_password" {
  description = "DocumentDB master password"
  type        = string
  default     = null
  sensitive   = true
}

# RDS Database passwords
variable "postgres_password" {
  description = "PostgreSQL master password"
  type        = string
  default     = null
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL master password"
  type        = string
  default     = null
  sensitive   = true
}

# IAM Users
variable "devops_users" {
  description = "Map of DevOps users"
  type = map(object({
    name = string
  }))
  default = {
    "devops1" = {
      name = "john.doe"
    }
  }
}

variable "developer_users" {
  description = "Map of Developer users"
  type = map(object({
    name = string
  }))
  default = {
    "dev1" = {
      name = "jane.smith"
    }
    "dev2" = {
      name = "bob.johnson"
    }
  }
}

variable "qa_users" {
  description = "Map of QA users"
  type = map(object({
    name = string
  }))
  default = {
    "qa1" = {
      name = "alice.wilson"
    }
  }
}

variable "readonly_users" {
  description = "Map of Read-only users"
  type = map(object({
    name = string
  }))
  default = {
    "readonly1" = {
      name = "charlie.brown"
    }
  }
}

# GitHub OIDC Configuration
variable "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN for CI/CD"
  type        = string
  default     = null
}

variable "github_repository_subjects" {
  description = "List of GitHub repository subjects for OIDC"
  type        = list(string)
  default = [
    "repo:your-org/your-repo:ref:refs/heads/main",
    "repo:your-org/your-repo:ref:refs/heads/dev"
  ]
}

# Security Configuration
variable "create_access_keys" {
  description = "Create access keys for users (not recommended for production)"
  type        = bool
  default     = true
}

variable "enforce_mfa" {
  description = "Enforce MFA for all users"
  type        = bool
  default     = false
}

# Domain and SSL Configuration
variable "domains" {
  description = "Map of domains and their configurations"
  type = map(object({
    domain_name         = string
    subdomains          = list(string)
    wildcard_subdomains = list(string)
    route53_zone_id     = string
    create_hosted_zone  = bool
    hosted_zone_type    = string # "public" or "private"
    vpc_id              = string # Required for private hosted zones
    load_balancer_type  = string # "external" or "internal"
    a_records = list(object({
      name = string
      type = string
      ttl  = number
    }))
    cname_records = list(object({
      name  = string
      value = string
      ttl   = number
    }))
  }))
  default = {
    primary = {
      domain_name         = "example.com"
      subdomains          = ["www", "api", "app"]
      wildcard_subdomains = []
      route53_zone_id     = null
      create_hosted_zone  = true
      hosted_zone_type    = "public"
      vpc_id              = null
      load_balancer_type  = "external"
      a_records = [
        {
          name = "dev.example.com"
          type = "A"
          ttl  = 300
        }
      ]
      cname_records = [
        {
          name  = "www.dev.example.com"
          value = "dev.example.com"
          ttl   = 300
        }
      ]
    }
  }
}

# DNS Resolver Configuration
variable "dns_resolver_config" {
  description = "DNS resolver configuration for VPC"
  type = object({
    enable_outbound_resolver = bool
    enable_inbound_resolver  = bool
    resolver_rules = map(object({
      domain_name = string
      name        = string
      target_ips  = list(string)
    }))
    inbound_resolver_rules = map(object({
      domain_name = string
      name        = string
    }))
  })
  default = {
    enable_outbound_resolver = true
    enable_inbound_resolver  = true
    resolver_rules = {
      "corporate-dns" = {
        domain_name = "corporate.example.com"
        name        = "corporate-dns-forward"
        target_ips  = ["8.8.8.8", "8.8.4.4"]
      }
    }
    inbound_resolver_rules = {
      "internal-domain" = {
        domain_name = "internal.example.com"
        name        = "internal-domain-resolver"
      }
    }
  }
} 