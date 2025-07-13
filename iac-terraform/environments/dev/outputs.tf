# Development Environment - Outputs

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = var.enable_vpc ? module.vpc[0].vpc_cidr_block : var.existing_vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = var.enable_vpc ? module.vpc[0].public_subnet_ids : var.existing_public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = var.enable_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = var.enable_eks ? module.eks[0].cluster_name : null
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = var.enable_eks ? module.eks[0].cluster_endpoint : var.existing_cluster_endpoint
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = var.enable_eks ? module.eks[0].cluster_arn : null
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = var.enable_eks ? module.eks[0].cluster_security_group_id : var.existing_cluster_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  value       = var.enable_eks ? module.eks[0].oidc_provider_arn : null
}

# NGINX Ingress Controller Outputs
output "ingress_controller_namespace" {
  description = "Namespace where NGINX Ingress Controllers are deployed"
  value       = var.enable_ingress ? module.ingress[0].ingress_controller_namespace : null
}

# External Controller Outputs
output "external_ingress_controller_service_name" {
  description = "Name of the external NGINX Ingress Controller service"
  value       = var.enable_ingress ? module.ingress[0].external_ingress_controller_service_name : null
}

output "external_ingress_class" {
  description = "Ingress class name for external NGINX Ingress Controller"
  value       = var.enable_ingress ? module.ingress[0].external_ingress_class : null
}

output "external_load_balancer_hostname" {
  description = "Hostname of the external load balancer"
  value       = var.enable_ingress ? module.ingress[0].external_load_balancer_hostname : var.existing_external_load_balancer_hostname
}

output "external_load_balancer_zone_id" {
  description = "Zone ID of the external load balancer for A record creation"
  value       = var.enable_ingress ? module.ingress[0].external_load_balancer_zone_id : var.existing_external_load_balancer_zone_id
}

output "external_metrics_endpoint" {
  description = "Metrics endpoint for external NGINX Ingress Controller"
  value       = var.enable_ingress ? module.ingress[0].external_metrics_endpoint : null
}

output "external_health_check_endpoint" {
  description = "Health check endpoint for external NGINX Ingress Controller"
  value       = var.enable_ingress ? module.ingress[0].external_health_check_endpoint : null
}

output "external_controller_status" {
  description = "Status of the external NGINX Ingress Controller deployment"
  value       = var.enable_ingress ? module.ingress[0].external_helm_release_status : null
}

# Internal Controller Outputs
output "internal_ingress_controller_service_name" {
  description = "Name of the internal NGINX Ingress Controller service"
  value       = var.enable_ingress ? module.ingress[0].internal_ingress_controller_service_name : null
}

output "internal_ingress_class" {
  description = "Ingress class name for internal NGINX Ingress Controller"
  value       = var.enable_ingress ? module.ingress[0].internal_ingress_class : null
}

output "internal_load_balancer_hostname" {
  description = "Hostname of the internal load balancer"
  value       = var.enable_ingress ? module.ingress[0].internal_load_balancer_hostname : var.existing_internal_load_balancer_hostname
}

output "internal_load_balancer_zone_id" {
  description = "Zone ID of the internal load balancer for A record creation"
  value       = var.enable_ingress ? module.ingress[0].internal_load_balancer_zone_id : var.existing_internal_load_balancer_zone_id
}

output "internal_metrics_endpoint" {
  description = "Metrics endpoint for internal NGINX Ingress Controller"
  value       = var.enable_ingress ? module.ingress[0].internal_metrics_endpoint : null
}

output "internal_health_check_endpoint" {
  description = "Health check endpoint for internal NGINX Ingress Controller"
  value       = var.enable_ingress ? module.ingress[0].internal_health_check_endpoint : null
}

output "internal_controller_status" {
  description = "Status of the internal NGINX Ingress Controller deployment"
  value       = var.enable_ingress ? module.ingress[0].internal_helm_release_status : null
}

# Shared Ingress Outputs
output "default_backend_service_name" {
  description = "Name of the default backend service"
  value       = var.enable_ingress ? module.ingress[0].default_backend_service_name : null
}

output "controllers_status" {
  description = "Status summary of both controllers"
  value       = var.enable_ingress ? module.ingress[0].controllers_status : null
}

# Karpenter Outputs (if enabled)
output "karpenter_controller_role_arn" {
  description = "Karpenter controller role ARN"
  value       = var.enable_dedicated_karpenter && var.enable_eks ? module.eks_karpenter[0].karpenter_controller_role_arn : null
}

output "karpenter_node_role_arn" {
  description = "Karpenter node role ARN"
  value       = var.enable_dedicated_karpenter && var.enable_eks ? module.eks_karpenter[0].karpenter_node_role_arn : null
}

# ACM Certificate Outputs
output "ssl_certificate_arns" {
  description = "Map of SSL certificate ARNs by domain"
  value       = var.enable_acm ? module.acm[0].certificate_arns : null
}

output "ssl_certificate_domains" {
  description = "Map of domain names"
  value       = var.enable_acm ? module.acm[0].certificate_domain_names : null
}

output "ssl_certificate_statuses" {
  description = "Map of SSL certificate statuses by domain"
  value       = var.enable_acm ? module.acm[0].certificate_statuses : null
}

output "primary_ssl_certificate_arn" {
  description = "Primary SSL certificate ARN"
  value       = var.enable_acm ? module.acm[0].primary_certificate_arn : var.existing_ssl_certificate_arn
}

# Route53 Hosted Zone Outputs
output "hosted_zone_ids" {
  description = "Map of hosted zone IDs by domain"
  value       = var.enable_acm ? module.acm[0].hosted_zone_ids : null
}

output "hosted_zone_nameservers" {
  description = "Map of nameservers for auto-created hosted zones"
  value       = var.enable_acm ? module.acm[0].hosted_zone_nameservers : null
}

output "a_record_fqdns" {
  description = "Map of domain keys to A record FQDNs"
  value       = var.enable_acm ? module.acm[0].a_record_fqdns : null
}

output "cname_record_fqdns" {
  description = "Map of CNAME record keys to FQDNs"
  value       = var.enable_acm ? module.acm[0].cname_record_fqdns : null
}

# Middleware Outputs
output "redis_endpoint" {
  description = "Redis endpoint"
  value       = var.enable_middleware ? module.middleware[0].redis_primary_endpoint : null
}

output "kafka_bootstrap_brokers" {
  description = "Kafka bootstrap brokers"
  value       = var.enable_middleware ? module.middleware[0].kafka_bootstrap_brokers : null
}

output "rabbitmq_console_url" {
  description = "RabbitMQ console URL"
  value       = var.enable_middleware ? module.middleware[0].rabbitmq_console_url : null
}

output "documentdb_endpoint" {
  description = "DocumentDB endpoint"
  value       = var.enable_middleware ? module.middleware[0].documentdb_endpoint : null
}

# PostgreSQL RDS Outputs
output "postgres_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = var.enable_postgres ? module.postgres[0].endpoint : null
}

output "postgres_port" {
  description = "PostgreSQL RDS port"
  value       = var.enable_postgres ? module.postgres[0].port : null
}

output "postgres_database_name" {
  description = "PostgreSQL database name"
  value       = var.enable_postgres ? module.postgres[0].database_name : null
}

output "postgres_master_username" {
  description = "PostgreSQL master username"
  value       = var.enable_postgres ? module.postgres[0].master_username : null
}

output "postgres_read_replica_endpoints" {
  description = "PostgreSQL read replica endpoints"
  value       = var.enable_postgres ? module.postgres[0].read_replica_endpoints : null
}

output "postgres_security_group_id" {
  description = "PostgreSQL security group ID"
  value       = var.enable_postgres ? module.postgres[0].security_group_id : null
}

output "postgres_ssm_parameter_name" {
  description = "SSM Parameter Store name for PostgreSQL password"
  value       = var.enable_postgres ? module.postgres[0].ssm_parameter_name : null
}

output "postgres_ssm_parameter_arn" {
  description = "SSM Parameter Store ARN for PostgreSQL password"
  value       = var.enable_postgres ? module.postgres[0].ssm_parameter_arn : null
}

# MySQL RDS Outputs
output "mysql_endpoint" {
  description = "MySQL RDS endpoint"
  value       = var.enable_mysql ? module.mysql[0].endpoint : null
}

output "mysql_port" {
  description = "MySQL RDS port"
  value       = var.enable_mysql ? module.mysql[0].port : null
}

output "mysql_database_name" {
  description = "MySQL database name"
  value       = var.enable_mysql ? module.mysql[0].database_name : null
}

output "mysql_master_username" {
  description = "MySQL master username"
  value       = var.enable_mysql ? module.mysql[0].master_username : null
}

output "mysql_read_replica_endpoints" {
  description = "MySQL read replica endpoints"
  value       = var.enable_mysql ? module.mysql[0].read_replica_endpoints : null
}

output "mysql_security_group_id" {
  description = "MySQL security group ID"
  value       = var.enable_mysql ? module.mysql[0].security_group_id : null
}

output "mysql_ssm_parameter_name" {
  description = "SSM Parameter Store name for MySQL password"
  value       = var.enable_mysql ? module.mysql[0].ssm_parameter_name : null
}

output "mysql_ssm_parameter_arn" {
  description = "SSM Parameter Store ARN for MySQL password"
  value       = var.enable_mysql ? module.mysql[0].ssm_parameter_arn : null
}

# IAM Outputs
output "ci_cd_pipeline_role_arn" {
  description = "CI/CD pipeline role ARN"
  value       = var.enable_iam ? module.iam[0].ci_cd_pipeline_role_arn : null
}

output "devops_group_name" {
  description = "DevOps group name"
  value       = var.enable_iam ? module.iam[0].devops_group_name : null
}

output "developers_group_name" {
  description = "Developers group name"
  value       = var.enable_iam ? module.iam[0].developers_group_name : null
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = local.github_oidc_provider_arn
}

# DNS Resolver Outputs
output "outbound_resolver_endpoint_id" {
  description = "ID of the outbound resolver endpoint"
  value       = var.enable_dns_resolver ? module.dns_resolver[0].outbound_resolver_endpoint_id : null
}

output "outbound_resolver_endpoint_ips" {
  description = "IP addresses of the outbound resolver endpoint"
  value       = var.enable_dns_resolver ? module.dns_resolver[0].outbound_resolver_endpoint_ips : null
}

output "inbound_resolver_endpoint_id" {
  description = "ID of the inbound resolver endpoint"
  value       = var.enable_dns_resolver ? module.dns_resolver[0].inbound_resolver_endpoint_id : null
}

output "inbound_resolver_endpoint_ips" {
  description = "IP addresses of the inbound resolver endpoint"
  value       = var.enable_dns_resolver ? module.dns_resolver[0].inbound_resolver_endpoint_ips : null
}

output "resolver_security_group_id" {
  description = "DNS resolver security group ID"
  value       = var.enable_dns_resolver ? module.dns_resolver[0].security_group_id : null
}

output "resolver_endpoints_status" {
  description = "Status of DNS resolver endpoints"
  value       = var.enable_dns_resolver ? module.dns_resolver[0].endpoints_status : null
}

# Utility Outputs
output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = var.enable_eks ? "aws eks update-kubeconfig --region ${module.globals.aws_region} --name ${module.eks[0].cluster_name}" : null
} 