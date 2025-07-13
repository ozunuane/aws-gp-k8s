# Development Environment - Main Configuration
# This file instantiates all modules for the development environment

# Import global variables
module "globals" {
  source = "../../globals"
}

# Local values for this environment
locals {
  environment = "dev"

  # Environment-specific tags
  tags = merge(module.globals.common_tags, {
    Environment = local.environment
  })
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  count  = var.enable_vpc ? 1 : 0

  environment          = local.environment
  vpc_cidr             = module.globals.vpc_cidr_blocks[local.environment]
  public_subnet_cidrs  = module.globals.public_subnet_cidrs[local.environment]
  private_subnet_cidrs = module.globals.private_subnet_cidrs[local.environment]
  enable_nat_gateway   = module.globals.enable_nat_gateway[local.environment]
  enable_vpc_endpoints = module.globals.enable_vpc_endpoints[local.environment]

  tags = local.tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"
  count  = var.enable_eks ? 1 : 0

  environment               = local.environment
  vpc_id                    = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  private_subnet_ids        = var.enable_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids
  public_subnet_ids         = var.enable_vpc ? module.vpc[0].public_subnet_ids : var.existing_public_subnet_ids
  kubernetes_version        = module.globals.kubernetes_versions[local.environment]
  node_group_instance_types = module.globals.node_instance_types[local.environment]
  node_group_min_size       = module.globals.node_scaling_config[local.environment].min_size
  node_group_max_size       = module.globals.node_scaling_config[local.environment].max_size
  node_group_desired_size   = module.globals.node_scaling_config[local.environment].desired_size
  enable_karpenter          = module.globals.enable_karpenter[local.environment]

  tags = local.tags
}

# NGINX Ingress Controller Module (Dual Load Balancers)
module "ingress" {
  source = "../../modules/ingress"
  count  = var.enable_ingress ? 1 : 0

  environment = local.environment

  # EKS cluster configuration
  cluster_endpoint       = var.enable_eks ? module.eks[0].cluster_endpoint : var.existing_cluster_endpoint
  cluster_ca_certificate = var.enable_eks ? module.eks[0].cluster_ca_certificate : var.existing_cluster_ca_certificate
  cluster_token          = var.enable_eks ? module.eks[0].cluster_token : var.existing_cluster_token

  # Network configuration
  public_subnet_ids  = var.enable_vpc ? module.vpc[0].public_subnet_ids : var.existing_public_subnet_ids
  private_subnet_ids = var.enable_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids

  # External Controller Configuration (Internet-facing)
  external_controller_replicas       = 1 # Single replica for dev
  external_controller_cpu_request    = "50m"
  external_controller_memory_request = "64Mi"
  external_controller_cpu_limit      = "100m"
  external_controller_memory_limit   = "128Mi"

  # Internal Controller Configuration (Private)
  internal_controller_replicas       = 1 # Single replica for dev
  internal_controller_cpu_request    = "25m"
  internal_controller_memory_request = "32Mi"
  internal_controller_cpu_limit      = "50m"
  internal_controller_memory_limit   = "64Mi"

  # Features
  enable_ssl_termination       = true # Enable SSL for dev
  ssl_certificate_arn          = var.enable_acm ? module.acm[0].certificate_arns["primary"] : var.existing_ssl_certificate_arn
  enable_access_logs           = true
  enable_metrics               = true
  enable_prometheus_monitoring = false # Disable for dev (cost savings)
  enable_admission_webhook     = true
  enable_default_backend       = true

  # Security
  enable_waf    = false # Disable WAF for dev (cost savings)
  enable_shield = false # Disable Shield for dev (cost savings)

  # Controller enablement
  enable_external_controller = true
  enable_internal_controller = true

  tags = local.tags
}

# ACM Certificate Module (for SSL termination)
module "acm" {
  source = "../../modules/acm"
  count  = var.enable_acm ? 1 : 0

  environment = local.environment

  # Domain configuration from terraform.tfvars with VPC ID for private zones
  domains = {
    for k, v in var.domains : k => merge(v, {
      vpc_id = v.hosted_zone_type == "private" ? (var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id) : null
    })
  }

  # External load balancer configuration for public domains
  load_balancer_dns_name = var.enable_ingress ? module.ingress[0].external_load_balancer_hostname : var.existing_external_load_balancer_hostname
  load_balancer_zone_id  = var.enable_ingress ? module.ingress[0].external_load_balancer_zone_id : var.existing_external_load_balancer_zone_id

  # Internal load balancer configuration for private domains
  internal_load_balancer_dns_name = var.enable_ingress ? module.ingress[0].internal_load_balancer_hostname : var.existing_internal_load_balancer_hostname
  internal_load_balancer_zone_id  = var.enable_ingress ? module.ingress[0].internal_load_balancer_zone_id : var.existing_internal_load_balancer_zone_id

  tags = local.tags

  depends_on = [module.ingress]
}

# DNS Resolver Module
module "dns_resolver" {
  source = "../../modules/dns-resolver"
  count  = var.enable_dns_resolver ? 1 : 0

  environment        = local.environment
  vpc_id             = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  vpc_cidr           = var.enable_vpc ? module.vpc[0].vpc_cidr_block : var.existing_vpc_cidr_block
  private_subnet_ids = var.enable_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids

  # Use configuration from tfvars
  enable_outbound_resolver = var.dns_resolver_config.enable_outbound_resolver
  enable_inbound_resolver  = var.dns_resolver_config.enable_inbound_resolver
  resolver_rules           = var.dns_resolver_config.resolver_rules
  inbound_resolver_rules   = var.dns_resolver_config.inbound_resolver_rules

  tags = local.tags

  depends_on = [module.vpc]
}

# EKS Karpenter Module (conditional)
module "eks_karpenter" {
  source = "../../modules/eks_karpenter"
  count  = var.enable_dedicated_karpenter && var.enable_eks ? 1 : 0

  environment             = local.environment
  cluster_name            = module.eks[0].cluster_name
  cluster_arn             = module.eks[0].cluster_arn
  cluster_oidc_issuer_url = module.eks[0].cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks[0].oidc_provider_arn

  tags = local.tags
}

# Middleware Module
module "middleware" {
  source = "../../modules/middleware"
  count  = var.enable_middleware ? 1 : 0

  environment        = local.environment
  vpc_id             = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  vpc_cidr           = var.enable_vpc ? module.vpc[0].vpc_cidr_block : var.existing_vpc_cidr_block
  private_subnet_ids = var.enable_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids

  # Enable services based on global configuration
  enable_redis      = module.globals.enable_middleware[local.environment].redis
  enable_kafka      = module.globals.enable_middleware[local.environment].kafka
  enable_rabbitmq   = module.globals.enable_middleware[local.environment].rabbitmq
  enable_documentdb = module.globals.enable_middleware[local.environment].documentdb

  # Service-specific configurations
  rabbitmq_password          = var.rabbitmq_password
  documentdb_master_password = var.documentdb_master_password

  tags = local.tags
}

# PostgreSQL RDS Module
module "postgres" {
  source = "../../modules/rds-postgres"
  count  = var.enable_postgres ? 1 : 0

  environment        = local.environment
  vpc_id             = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  private_subnet_ids = var.enable_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [
    var.enable_eks ? module.eks[0].cluster_security_group_id : var.existing_cluster_security_group_id,
    var.enable_middleware ? module.middleware[0].redis_security_group_id : var.existing_redis_security_group_id
  ]
  allowed_cidr_blocks = [var.enable_vpc ? module.vpc[0].vpc_cidr_block : var.existing_vpc_cidr_block]

  # Engine configuration
  engine_version       = "15.4"
  engine_version_major = "15"
  instance_class       = "db.t3.micro"

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  database_name            = "myapp_dev"
  master_username          = "postgres"
  generate_random_password = true

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = false

  # Performance Insights
  performance_insights_enabled          = false # Disable for dev (cost savings)
  performance_insights_retention_period = 7

  # Monitoring
  monitoring_interval = 0 # Disable enhanced monitoring for dev (cost savings)

  # Logging
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Parameter Group
  parameter_group_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]

  # Multi-AZ and Deletion Protection
  multi_az            = false # Disable for dev (cost savings)
  deletion_protection = false # Allow deletion for dev

  # No read replicas for dev (cost savings)
  read_replicas = {}

  tags = local.tags
}

# MySQL RDS Module
module "mysql" {
  source = "../../modules/rds-mysql"
  count  = var.enable_mysql ? 1 : 0

  environment        = local.environment
  vpc_id             = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  private_subnet_ids = var.enable_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [
    var.enable_eks ? module.eks[0].cluster_security_group_id : var.existing_cluster_security_group_id,
    var.enable_middleware ? module.middleware[0].redis_security_group_id : var.existing_redis_security_group_id
  ]
  allowed_cidr_blocks = [var.enable_vpc ? module.vpc[0].vpc_cidr_block : var.existing_vpc_cidr_block]

  # Engine configuration
  engine_version       = "8.0.35"
  engine_version_major = "8.0"
  instance_class       = "db.t3.micro"

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  database_name            = "myapp_dev"
  master_username          = "admin"
  generate_random_password = true

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = false

  # Performance Insights
  performance_insights_enabled          = false # Disable for dev (cost savings)
  performance_insights_retention_period = 7

  # Monitoring
  monitoring_interval = 0 # Disable enhanced monitoring for dev (cost savings)

  # Logging
  enabled_cloudwatch_logs_exports = ["error", "general", "slow_query"]

  # Parameter Group
  parameter_group_parameters = [
    {
      name  = "slow_query_log"
      value = "1"
    },
    {
      name  = "long_query_time"
      value = "2"
    }
  ]

  # Multi-AZ and Deletion Protection
  multi_az            = false # Disable for dev (cost savings)
  deletion_protection = false # Allow deletion for dev

  # No read replicas for dev (cost savings)
  read_replicas = {}

  tags = local.tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  count  = var.enable_iam ? 1 : 0

  environment = local.environment

  # User configurations
  devops_users    = var.devops_users
  developer_users = var.developer_users
  qa_users        = var.qa_users
  readonly_users  = var.readonly_users

  # GitHub OIDC configuration
  github_oidc_provider_arn   = local.github_oidc_provider_arn
  github_repository_subjects = var.github_repository_subjects

  # Security configurations
  create_access_keys = var.create_access_keys
  enforce_mfa        = var.enforce_mfa

  tags = local.tags
} 