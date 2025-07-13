# VPC Module - Variables

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

variable "vpc_endpoints_config" {
  description = "Configuration for which VPC endpoints to enable"
  type = object({
    s3             = bool
    ec2            = bool
    ecr_api        = bool
    ecr_dkr        = bool
    eks            = bool
    logs           = bool
    secretsmanager = bool
    ssm            = bool
    ssm_messages   = bool
    ec2_messages   = bool
  })
  default = {
    s3             = true
    ec2            = true
    ecr_api        = true
    ecr_dkr        = true
    eks            = true
    logs           = true
    secretsmanager = true
    ssm            = true
    ssm_messages   = true
    ec2_messages   = true
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
} 