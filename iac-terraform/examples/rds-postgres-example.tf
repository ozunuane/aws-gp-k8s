# Example: PostgreSQL RDS Module Usage
# This shows how to use the PostgreSQL RDS module in your environment

# PostgreSQL RDS Module
module "postgres" {
  source = "../modules/rds-postgres"

  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [
    module.eks.cluster_security_group_id,
    module.middleware.redis_security_group_id
  ]
  allowed_cidr_blocks = ["10.0.0.0/16"] # VPC CIDR

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
  database_name   = "myapp"
  master_username = "postgres"
  master_password = var.postgres_password

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = false

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = module.iam.rds_monitoring_role_arn

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
    },
    {
      name  = "log_statement"
      value = "all"
    }
  ]

  # Multi-AZ
  multi_az = false # Enable for production

  # Deletion protection
  deletion_protection = false # Enable for production

  # Read Replicas (optional)
  read_replicas = {
    "read-1" = {
      instance_class               = "db.t3.micro"
      availability_zone            = "us-west-2b"
      performance_insights_enabled = true
      deletion_protection          = false
    }
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
    Database    = "postgres"
  }
}

# Example outputs
output "postgres_endpoint" {
  description = "PostgreSQL endpoint"
  value       = module.postgres.instance_endpoint
}

output "postgres_connection_info" {
  description = "PostgreSQL connection information"
  value       = module.postgres.connection_info
  sensitive   = true
}

output "postgres_security_group_id" {
  description = "PostgreSQL security group ID"
  value       = module.postgres.security_group_id
}

output "postgres_read_replica_endpoints" {
  description = "PostgreSQL read replica endpoints"
  value       = module.postgres.read_replica_endpoints
} 