# Example: MySQL RDS Module Usage
# This shows how to use the MySQL RDS module in your environment

# MySQL RDS Module
module "mysql" {
  source = "../modules/rds-mysql"

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
  engine_version       = "8.0.35"
  engine_version_major = "8.0"
  instance_class       = "db.t3.micro"

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database configuration
  database_name   = "myapp"
  master_username = "admin"
  master_password = var.mysql_password

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
    },
    {
      name  = "log_queries_not_using_indexes"
      value = "1"
    },
    {
      name  = "innodb_buffer_pool_size"
      value = "{DBInstanceClassMemory*3/4}"
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
    Database    = "mysql"
  }
}

# Example outputs
output "mysql_endpoint" {
  description = "MySQL endpoint"
  value       = module.mysql.instance_endpoint
}

output "mysql_connection_info" {
  description = "MySQL connection information"
  value       = module.mysql.connection_info
  sensitive   = true
}

output "mysql_security_group_id" {
  description = "MySQL security group ID"
  value       = module.mysql.security_group_id
}

output "mysql_read_replica_endpoints" {
  description = "MySQL read replica endpoints"
  value       = module.mysql.read_replica_endpoints
} 