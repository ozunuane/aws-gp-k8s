# Production Environment - Main Configuration
# This file instantiates all modules for the production environment

# Local values for this environment
locals {
  environment = "prod"

  # Load global variables
  global_vars = var.global_config

  # Environment-specific tags
  tags = merge(local.global_vars.common_tags, {
    Environment = local.environment
  })
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment          = local.environment
  vpc_cidr             = local.global_vars.vpc_cidr_blocks[local.environment]
  public_subnet_cidrs  = local.global_vars.public_subnet_cidrs[local.environment]
  private_subnet_cidrs = local.global_vars.private_subnet_cidrs[local.environment]
  enable_nat_gateway   = local.global_vars.enable_nat_gateway[local.environment]
  enable_vpc_endpoints = local.global_vars.enable_vpc_endpoints[local.environment]

  tags = local.tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  environment               = local.environment
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  kubernetes_version        = local.global_vars.kubernetes_versions[local.environment]
  node_group_instance_types = local.global_vars.node_instance_types[local.environment]
  node_group_min_size       = local.global_vars.node_scaling_config[local.environment].min_size
  node_group_max_size       = local.global_vars.node_scaling_config[local.environment].max_size
  node_group_desired_size   = local.global_vars.node_scaling_config[local.environment].desired_size
  enable_karpenter          = local.global_vars.enable_karpenter[local.environment]

  tags = local.tags
}

# NGINX Ingress Controller Module (Dual Load Balancers)
module "ingress" {
  source = "../../modules/ingress"

  environment = local.environment

  # EKS cluster configuration
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  cluster_token          = module.eks.cluster_token

  # Network configuration
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  # External Controller Configuration (Internet-facing)
  external_controller_replicas       = 3 # Multiple replicas for production
  external_controller_cpu_request    = "200m"
  external_controller_memory_request = "256Mi"
  external_controller_cpu_limit      = "500m"
  external_controller_memory_limit   = "512Mi"

  # Internal Controller Configuration (Private)
  internal_controller_replicas       = 2 # Multiple replicas for production
  internal_controller_cpu_request    = "100m"
  internal_controller_memory_request = "128Mi"
  internal_controller_cpu_limit      = "200m"
  internal_controller_memory_limit   = "256Mi"

  # Features
  enable_ssl_termination       = true # Enable SSL for production
  enable_access_logs           = true
  enable_metrics               = true
  enable_prometheus_monitoring = true # Enable monitoring for production
  enable_admission_webhook     = true
  enable_default_backend       = true

  # Security
  enable_waf    = true # Enable WAF for production
  enable_shield = true # Enable Shield for production

  # Controller enablement
  enable_external_controller = true
  enable_internal_controller = true

  # Node placement for critical workloads in production
  node_selector = {
    "karpenter.sh/capacity-type" = "on-demand"
  }

  tolerations = [
    {
      key      = "workload-type"
      operator = "Equal"
      value    = "critical"
      effect   = "NoSchedule"
    }
  ]

  tags = local.tags
}

# EKS Karpenter Module (conditional)
module "eks_karpenter" {
  source = "../../modules/eks_karpenter"
  count  = var.enable_dedicated_karpenter ? 1 : 0

  environment             = local.environment
  cluster_name            = module.eks.cluster_name
  cluster_arn             = module.eks.cluster_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn

  tags = local.tags
}

# Middleware Module
module "middleware" {
  source = "../../modules/middleware"

  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnet_ids

  # Enable services based on global configuration
  enable_redis      = local.global_vars.enable_middleware[local.environment].redis
  enable_kafka      = local.global_vars.enable_middleware[local.environment].kafka
  enable_rabbitmq   = local.global_vars.enable_middleware[local.environment].rabbitmq
  enable_documentdb = local.global_vars.enable_middleware[local.environment].documentdb

  # Service-specific configurations
  rabbitmq_password          = var.rabbitmq_password
  documentdb_master_password = var.documentdb_master_password

  tags = local.tags
}

# PostgreSQL RDS Module
module "postgres" {
  source = "../../modules/rds-postgres"

  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [
    module.eks.cluster_security_group_id,
    module.middleware.redis_security_group_id
  ]
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  # Engine configuration
  engine_version       = "15.4"
  engine_version_major = "15"
  instance_class       = "db.r6g.large"

  # Storage configuration
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  database_name            = "myapp_prod"
  master_username          = "postgres"
  generate_random_password = true

  # Backup configuration
  backup_retention_period = 35
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:03:00-sun:04:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = false

  # Performance Insights
  performance_insights_enabled          = true # Enable for production
  performance_insights_retention_period = 30

  # Monitoring
  monitoring_interval = 60 # Enable enhanced monitoring for production

  # Logging
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Parameter Group
  parameter_group_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements,auto_explain,pg_stat_monitor"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_checkpoints"
      value = "on"
    },
    {
      name  = "log_connections"
      value = "on"
    },
    {
      name  = "log_disconnections"
      value = "on"
    }
  ]

  # Multi-AZ and Deletion Protection
  multi_az            = true # Enable for production
  deletion_protection = true # Enable for production

  # Multiple read replicas for production
  read_replicas = {
    "read-1" = {
      instance_class               = "db.r6g.large"
      availability_zone            = "us-west-2b"
      performance_insights_enabled = true
      deletion_protection          = true
      backup_retention_period      = 7
      monitoring_interval          = 60
    },
    "read-2" = {
      instance_class               = "db.r6g.large"
      availability_zone            = "us-west-2c"
      performance_insights_enabled = true
      deletion_protection          = true
      backup_retention_period      = 7
      monitoring_interval          = 60
    }
  }

  tags = local.tags
}

# MySQL RDS Module
module "mysql" {
  source = "../../modules/rds-mysql"

  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [
    module.eks.cluster_security_group_id,
    module.middleware.redis_security_group_id
  ]
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  # Engine configuration
  engine_version       = "8.0.35"
  engine_version_major = "8.0"
  instance_class       = "db.r6g.large"

  # Storage configuration
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  database_name            = "myapp_prod"
  master_username          = "admin"
  generate_random_password = true

  # Backup configuration
  backup_retention_period = 35
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:03:00-sun:04:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = false

  # Performance Insights
  performance_insights_enabled          = true # Enable for production
  performance_insights_retention_period = 30

  # Monitoring
  monitoring_interval = 60 # Enable enhanced monitoring for production

  # Logging
  enabled_cloudwatch_logs_exports = ["error", "general", "slow_query", "audit"]

  # Parameter Group
  parameter_group_parameters = [
    {
      name  = "slow_query_log"
      value = "1"
    },
    {
      name  = "long_query_time"
      value = "2"
    },
    {
      name  = "log_queries_not_using_indexes"
      value = "1"
    },
    {
      name  = "log_error_verbosity"
      value = "3"
    },
    {
      name  = "innodb_log_file_size"
      value = "268435456"
    },
    {
      name  = "innodb_buffer_pool_size"
      value = "{DBInstanceClassMemory*3/4}"
    }
  ]

  # Multi-AZ and Deletion Protection
  multi_az            = true # Enable for production
  deletion_protection = true # Enable for production

  # Multiple read replicas for production
  read_replicas = {
    "read-1" = {
      instance_class               = "db.r6g.large"
      availability_zone            = "us-west-2b"
      performance_insights_enabled = true
      deletion_protection          = true
      backup_retention_period      = 7
      monitoring_interval          = 60
    },
    "read-2" = {
      instance_class               = "db.r6g.large"
      availability_zone            = "us-west-2c"
      performance_insights_enabled = true
      deletion_protection          = true
      backup_retention_period      = 7
      monitoring_interval          = 60
    }
  }

  tags = local.tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

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

# ACM Certificate Module (for SSL termination)
module "acm" {
  source = "../../modules/acm"

  environment = local.environment

  # Domain configuration from terraform.tfvars with VPC ID for private zones
  domains = {
    for k, v in var.domains : k => merge(v, {
      vpc_id = v.hosted_zone_type == "private" ? module.vpc.vpc_id : null
    })
  }

  # External load balancer configuration for public domains
  load_balancer_dns_name = module.ingress.external_load_balancer_hostname
  load_balancer_zone_id  = module.ingress.external_load_balancer_zone_id

  # Internal load balancer configuration for private domains
  internal_load_balancer_dns_name = module.ingress.internal_load_balancer_hostname
  internal_load_balancer_zone_id  = module.ingress.internal_load_balancer_zone_id

  tags = local.tags

  depends_on = [module.ingress]
}

# DNS Resolver Module
module "dns_resolver" {
  source = "../../modules/dns-resolver"

  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnet_ids

  # Use configuration from tfvars
  enable_outbound_resolver = var.dns_resolver_config.enable_outbound_resolver
  enable_inbound_resolver  = var.dns_resolver_config.enable_inbound_resolver
  resolver_rules           = var.dns_resolver_config.resolver_rules
  inbound_resolver_rules   = var.dns_resolver_config.inbound_resolver_rules

  tags = local.tags

  depends_on = [module.vpc]
} 