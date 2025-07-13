# Globals Module - Outputs
# Output all global variables for use by other modules

output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "organization" {
  description = "Organization name"
  value       = var.organization
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "availability_zones" {
  description = "List of availability zones"
  value       = var.availability_zones
}

output "common_tags" {
  description = "Common tags to apply to all resources"
  value       = var.common_tags
}

# VPC Configuration
output "vpc_cidr_blocks" {
  description = "VPC CIDR blocks for each environment"
  value       = var.vpc_cidr_blocks
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks for each environment"
  value       = var.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks for each environment"
  value       = var.private_subnet_cidrs
}

# EKS Configuration
output "kubernetes_versions" {
  description = "Kubernetes versions for each environment"
  value       = var.kubernetes_versions
}

output "node_instance_types" {
  description = "Node instance types for each environment"
  value       = var.node_instance_types
}

output "node_scaling_config" {
  description = "Node scaling configuration for each environment"
  value       = var.node_scaling_config
}

# Environment-specific features
output "enable_karpenter" {
  description = "Enable Karpenter for each environment"
  value       = var.enable_karpenter
}

output "enable_nat_gateway" {
  description = "Enable NAT Gateway for each environment"
  value       = var.enable_nat_gateway
}

output "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for each environment"
  value       = var.enable_vpc_endpoints
}

# Middleware Configuration
output "enable_middleware" {
  description = "Enable middleware services for each environment"
  value       = var.enable_middleware
} 