# PostgreSQL RDS Module - Outputs

# Main Instance Outputs
output "instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.postgres.id
}

output "instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.postgres.arn
}

output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "address" {
  description = "RDS instance address"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "master_username" {
  description = "Master username"
  value       = aws_db_instance.postgres.username
}

output "instance_status" {
  description = "RDS instance status"
  value       = aws_db_instance.postgres.status
}

output "instance_availability_zone" {
  description = "RDS instance availability zone"
  value       = aws_db_instance.postgres.availability_zone
}

output "instance_multi_az" {
  description = "Whether the RDS instance is Multi-AZ"
  value       = aws_db_instance.postgres.multi_az
}

# SSM Parameter Store Outputs
output "ssm_parameter_name" {
  description = "SSM Parameter Store name for the password"
  value       = var.generate_random_password ? aws_ssm_parameter.postgres_password[0].name : null
}

output "ssm_parameter_arn" {
  description = "SSM Parameter Store ARN for the password"
  value       = var.generate_random_password ? aws_ssm_parameter.postgres_password[0].arn : null
}

output "ssm_parameter_version" {
  description = "SSM Parameter Store version for the password"
  value       = var.generate_random_password ? aws_ssm_parameter.postgres_password[0].version : null
}

# Security Group Outputs
output "security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = aws_security_group.postgres.id
}

output "security_group_arn" {
  description = "Security group ARN for the RDS instance"
  value       = aws_security_group.postgres.arn
}

# Subnet Group Outputs
output "subnet_group_id" {
  description = "DB subnet group ID"
  value       = aws_db_subnet_group.postgres.id
}

output "subnet_group_arn" {
  description = "DB subnet group ARN"
  value       = aws_db_subnet_group.postgres.arn
}

output "subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.postgres.name
}

# Parameter Group Outputs
output "parameter_group_id" {
  description = "DB parameter group ID"
  value       = aws_db_parameter_group.postgres.id
}

output "parameter_group_arn" {
  description = "DB parameter group ARN"
  value       = aws_db_parameter_group.postgres.arn
}

output "parameter_group_name" {
  description = "DB parameter group name"
  value       = aws_db_parameter_group.postgres.name
}

# Option Group Outputs
output "option_group_id" {
  description = "DB option group ID"
  value       = length(var.option_group_options) > 0 ? aws_db_option_group.postgres[0].id : null
}

output "option_group_arn" {
  description = "DB option group ARN"
  value       = length(var.option_group_options) > 0 ? aws_db_option_group.postgres[0].arn : null
}

output "option_group_name" {
  description = "DB option group name"
  value       = length(var.option_group_options) > 0 ? aws_db_option_group.postgres[0].name : null
}

# Read Replica Outputs
output "read_replica_endpoints" {
  description = "Map of read replica endpoints"
  value = {
    for k, v in aws_db_instance.postgres_read_replicas : k => {
      id       = v.id
      arn      = v.arn
      endpoint = v.endpoint
      address  = v.address
      port     = v.port
      status   = v.status
      az       = v.availability_zone
    }
  }
}

output "read_replica_ids" {
  description = "List of read replica instance IDs"
  value       = [for replica in aws_db_instance.postgres_read_replicas : replica.id]
}

output "read_replica_arns" {
  description = "List of read replica instance ARNs"
  value       = [for replica in aws_db_instance.postgres_read_replicas : replica.arn]
}

# Connection Information
output "connection_info" {
  description = "Database connection information"
  value = {
    host                   = aws_db_instance.postgres.address
    port                   = aws_db_instance.postgres.port
    database               = aws_db_instance.postgres.db_name
    username               = aws_db_instance.postgres.username
    endpoint               = aws_db_instance.postgres.endpoint
    password_ssm_parameter = var.generate_random_password ? aws_ssm_parameter.postgres_password[0].name : null
  }
  sensitive = true
}

# Backup and Snapshot Information
output "latest_restorable_time" {
  description = "Latest restorable time for the RDS instance"
  value       = aws_db_instance.postgres.latest_restorable_time
}

output "backup_retention_period" {
  description = "Backup retention period in days"
  value       = aws_db_instance.postgres.backup_retention_period
}

output "backup_window" {
  description = "Backup window"
  value       = aws_db_instance.postgres.backup_window
}

output "maintenance_window" {
  description = "Maintenance window"
  value       = aws_db_instance.postgres.maintenance_window
}

# Performance Insights
output "performance_insights_enabled" {
  description = "Whether Performance Insights is enabled"
  value       = aws_db_instance.postgres.performance_insights_enabled
}

output "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  value       = aws_db_instance.postgres.performance_insights_retention_period
}

# Monitoring
output "monitoring_interval" {
  description = "Monitoring interval in seconds"
  value       = aws_db_instance.postgres.monitoring_interval
}

output "monitoring_role_arn" {
  description = "IAM role ARN for monitoring"
  value       = aws_db_instance.postgres.monitoring_role_arn
}

# Storage Information
output "allocated_storage" {
  description = "Allocated storage in GB"
  value       = aws_db_instance.postgres.allocated_storage
}

output "max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  value       = aws_db_instance.postgres.max_allocated_storage
}

output "storage_type" {
  description = "Storage type"
  value       = aws_db_instance.postgres.storage_type
}

output "storage_encrypted" {
  description = "Whether storage is encrypted"
  value       = aws_db_instance.postgres.storage_encrypted
}

# Engine Information
output "engine" {
  description = "Database engine"
  value       = aws_db_instance.postgres.engine
}

output "engine_version" {
  description = "Database engine version"
  value       = aws_db_instance.postgres.engine_version
}

output "instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.postgres.instance_class
}

# Network Information
output "publicly_accessible" {
  description = "Whether the database is publicly accessible"
  value       = aws_db_instance.postgres.publicly_accessible
}

output "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  value       = aws_db_instance.postgres.vpc_security_group_ids
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_instance.postgres.db_subnet_group_name
}

# Resource Tags
output "tags" {
  description = "Tags applied to the RDS instance"
  value       = aws_db_instance.postgres.tags
} 