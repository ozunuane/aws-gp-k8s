# Production Environment - Outputs

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

# Karpenter Outputs (if enabled)
output "karpenter_controller_role_arn" {
  description = "Karpenter controller role ARN"
  value       = var.enable_dedicated_karpenter ? module.eks_karpenter[0].karpenter_controller_role_arn : null
}

output "karpenter_node_role_arn" {
  description = "Karpenter node role ARN"
  value       = var.enable_dedicated_karpenter ? module.eks_karpenter[0].karpenter_node_role_arn : null
}

# Ingress Outputs
output "external_ingress_load_balancer_dns" {
  description = "External NGINX ingress load balancer DNS"
  value       = module.ingress.external_ingress_load_balancer_dns
}

output "internal_ingress_load_balancer_dns" {
  description = "Internal NGINX ingress load balancer DNS"
  value       = module.ingress.internal_ingress_load_balancer_dns
}

output "external_ingress_service_name" {
  description = "External NGINX ingress service name"
  value       = module.ingress.external_ingress_service_name
}

output "internal_ingress_service_name" {
  description = "Internal NGINX ingress service name"
  value       = module.ingress.internal_ingress_service_name
}

# Middleware Outputs
output "redis_endpoint" {
  description = "Redis endpoint"
  value       = module.middleware.redis_primary_endpoint
}

output "kafka_bootstrap_brokers" {
  description = "Kafka bootstrap brokers"
  value       = module.middleware.kafka_bootstrap_brokers
}

output "rabbitmq_console_url" {
  description = "RabbitMQ console URL"
  value       = module.middleware.rabbitmq_console_url
}

output "documentdb_endpoint" {
  description = "DocumentDB endpoint"
  value       = module.middleware.documentdb_endpoint
}

# PostgreSQL RDS Outputs
output "postgres_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = module.postgres.endpoint
}

output "postgres_port" {
  description = "PostgreSQL RDS port"
  value       = module.postgres.port
}

output "postgres_database_name" {
  description = "PostgreSQL database name"
  value       = module.postgres.database_name
}

output "postgres_master_username" {
  description = "PostgreSQL master username"
  value       = module.postgres.master_username
}

output "postgres_read_replica_endpoints" {
  description = "PostgreSQL read replica endpoints"
  value       = module.postgres.read_replica_endpoints
}

output "postgres_security_group_id" {
  description = "PostgreSQL security group ID"
  value       = module.postgres.security_group_id
}

output "postgres_ssm_parameter_name" {
  description = "SSM Parameter Store name for PostgreSQL password"
  value       = module.postgres.ssm_parameter_name
}

output "postgres_ssm_parameter_arn" {
  description = "SSM Parameter Store ARN for PostgreSQL password"
  value       = module.postgres.ssm_parameter_arn
}

# MySQL RDS Outputs
output "mysql_endpoint" {
  description = "MySQL RDS endpoint"
  value       = module.mysql.endpoint
}

output "mysql_port" {
  description = "MySQL RDS port"
  value       = module.mysql.port
}

output "mysql_database_name" {
  description = "MySQL database name"
  value       = module.mysql.database_name
}

output "mysql_master_username" {
  description = "MySQL master username"
  value       = module.mysql.master_username
}

output "mysql_read_replica_endpoints" {
  description = "MySQL read replica endpoints"
  value       = module.mysql.read_replica_endpoints
}

output "mysql_security_group_id" {
  description = "MySQL security group ID"
  value       = module.mysql.security_group_id
}

output "mysql_ssm_parameter_name" {
  description = "SSM Parameter Store name for MySQL password"
  value       = module.mysql.ssm_parameter_name
}

output "mysql_ssm_parameter_arn" {
  description = "SSM Parameter Store ARN for MySQL password"
  value       = module.mysql.ssm_parameter_arn
}

# IAM Outputs
output "ci_cd_pipeline_role_arn" {
  description = "CI/CD pipeline role ARN"
  value       = module.iam.ci_cd_pipeline_role_arn
}

output "devops_group_name" {
  description = "DevOps group name"
  value       = module.iam.devops_group_name
}

output "developers_group_name" {
  description = "Developers group name"
  value       = module.iam.developers_group_name
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

# Kubeconfig Command
output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.global_config.aws_region} --name ${module.eks.cluster_name}"
} 