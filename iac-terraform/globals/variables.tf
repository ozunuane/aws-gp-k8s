# Global Variables
# Shared configuration across all environments

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws-gp-k8s"
}

variable "organization" {
  description = "Organization name"
  type        = string
  default     = "godspower"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project      = "aws-gp-k8s"
    Organization = "godspower"
    ManagedBy    = "terraform"
  }
}

# VPC Configuration
variable "vpc_cidr_blocks" {
  description = "VPC CIDR blocks for each environment"
  type        = map(string)
  default = {
    dev     = "10.0.0.0/16"
    staging = "10.1.0.0/16"
    prod    = "10.2.0.0/16"
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks for each environment"
  type        = map(list(string))
  default = {
    dev = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24"
    ]
    staging = [
      "10.1.1.0/24",
      "10.1.2.0/24",
      "10.1.3.0/24"
    ]
    prod = [
      "10.2.1.0/24",
      "10.2.2.0/24",
      "10.2.3.0/24"
    ]
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks for each environment"
  type        = map(list(string))
  default = {
    dev = [
      "10.0.11.0/24",
      "10.0.12.0/24",
      "10.0.13.0/24"
    ]
    staging = [
      "10.1.11.0/24",
      "10.1.12.0/24",
      "10.1.13.0/24"
    ]
    prod = [
      "10.2.11.0/24",
      "10.2.12.0/24",
      "10.2.13.0/24"
    ]
  }
}

# EKS Configuration
variable "kubernetes_versions" {
  description = "Kubernetes versions for each environment"
  type        = map(string)
  default = {
    dev     = "1.28"
    staging = "1.28"
    prod    = "1.28"
  }
}

variable "node_instance_types" {
  description = "Node instance types for each environment"
  type        = map(list(string))
  default = {
    dev     = ["t3.medium"]
    staging = ["t3.large", "t3.xlarge"]
    prod    = ["m5.large", "m5.xlarge"]
  }
}

variable "node_scaling_config" {
  description = "Node scaling configuration for each environment"
  type = map(object({
    min_size     = number
    max_size     = number
    desired_size = number
  }))
  default = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
    staging = {
      min_size     = 2
      max_size     = 6
      desired_size = 3
    }
    prod = {
      min_size     = 3
      max_size     = 10
      desired_size = 5
    }
  }
}

# Environment-specific features
variable "enable_karpenter" {
  description = "Enable Karpenter for each environment"
  type        = map(bool)
  default = {
    dev     = false
    staging = true
    prod    = true
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for each environment"
  type        = map(bool)
  default = {
    dev     = false
    staging = true
    prod    = true
  }
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for each environment"
  type        = map(bool)
  default = {
    dev     = false
    staging = true
    prod    = true
  }
}

# Middleware Configuration
variable "enable_middleware" {
  description = "Enable middleware services for each environment"
  type = map(object({
    redis      = bool
    kafka      = bool
    rabbitmq   = bool
    documentdb = bool
  }))
  default = {
    dev = {
      redis      = false
      kafka      = false
      rabbitmq   = false
      documentdb = false
    }
    staging = {
      redis      = false
      kafka      = false
      rabbitmq   = false
      documentdb = false
    }
    prod = {
      redis      = true
      kafka      = true
      rabbitmq   = true
      documentdb = true
    }
  }
} 