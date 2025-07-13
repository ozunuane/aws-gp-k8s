# Staging Environment - Variables

# Global configuration
variable "global_config" {
  description = "Global configuration from globals/variables.tf"
  type = object({
    project_name         = string
    organization         = string
    aws_region           = string
    common_tags          = map(string)
    vpc_cidr_blocks      = map(string)
    public_subnet_cidrs  = map(list(string))
    private_subnet_cidrs = map(list(string))
    kubernetes_versions  = map(string)
    node_instance_types  = map(list(string))
    node_scaling_config = map(object({
      min_size     = number
      max_size     = number
      desired_size = number
    }))
    enable_karpenter     = map(bool)
    enable_nat_gateway   = map(bool)
    enable_vpc_endpoints = map(bool)
    enable_middleware = map(object({
      redis      = bool
      kafka      = bool
      rabbitmq   = bool
      documentdb = bool
    }))
  })
}

# Environment-specific features
variable "enable_dedicated_karpenter" {
  description = "Enable dedicated Karpenter module (separate from EKS module)"
  type        = bool
  default     = false
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
          name = "staging.example.com"
          type = "A"
          ttl  = 300
        }
      ]
      cname_records = [
        {
          name  = "www.staging.example.com"
          value = "staging.example.com"
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