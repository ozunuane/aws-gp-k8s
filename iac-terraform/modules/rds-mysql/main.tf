# MySQL RDS Module - Main Configuration

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# Random password generation
resource "random_password" "mysql_password" {
  count = var.generate_random_password ? 1 : 0

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

# SSM Parameter Store for password
resource "aws_ssm_parameter" "mysql_password" {
  count = var.generate_random_password ? 1 : 0

  name        = "/${var.environment}/rds/mysql/password"
  description = "MySQL master password for ${var.environment} environment"
  type        = "SecureString"
  value       = random_password.mysql_password[0].result

  tags = merge(var.tags, {
    Name = "${var.environment}-mysql-password"
  })
}

# Use provided password or generated password
locals {
  master_password = var.generate_random_password ? random_password.mysql_password[0].result : var.master_password
}

# Subnet Group
resource "aws_db_subnet_group" "mysql" {
  name       = "${var.environment}-mysql-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.environment}-mysql-subnet-group"
  })
}

# Security Group
resource "aws_security_group" "mysql" {
  name_prefix = "${var.environment}-mysql-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "MySQL from allowed security groups"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "MySQL from allowed CIDR blocks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-mysql-security-group"
  })
}

# Parameter Group
resource "aws_db_parameter_group" "mysql" {
  family = "mysql${var.engine_version_major}"

  name_prefix = "${var.environment}-mysql-params-"

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-mysql-parameter-group"
  })
}

# Option Group (if needed)
resource "aws_db_option_group" "mysql" {
  count = length(var.option_group_options) > 0 ? 1 : 0

  name_prefix          = "${var.environment}-mysql-options-"
  engine_name          = "mysql"
  major_engine_version = var.engine_version_major

  dynamic "option" {
    for_each = var.option_group_options
    content {
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-mysql-option-group"
  })
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier = "${var.environment}-mysql"

  # Engine configuration
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  publicly_accessible    = var.publicly_accessible
  port                   = 3306

  # Database configuration
  db_name  = var.database_name
  username = var.master_username
  password = local.master_password

  # Backup configuration
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-mysql-final-snapshot"

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  # Logging
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.mysql.name
  option_group_name    = length(var.option_group_options) > 0 ? aws_db_option_group.mysql[0].name : null

  # Multi-AZ and Read Replicas
  multi_az          = var.multi_az
  availability_zone = var.availability_zone

  # Deletion protection
  deletion_protection = var.deletion_protection

  # Tags
  tags = merge(var.tags, {
    Name = "${var.environment}-mysql-instance"
  })

  depends_on = [
    aws_db_subnet_group.mysql,
    aws_security_group.mysql,
    aws_db_parameter_group.mysql
  ]
}

# Read Replicas (if enabled)
resource "aws_db_instance" "mysql_read_replicas" {
  for_each = var.read_replicas

  identifier = "${var.environment}-mysql-read-${each.key}"

  # Source instance
  replicate_source_db = aws_db_instance.mysql.identifier

  # Engine configuration
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = each.value.instance_class

  # Storage configuration
  allocated_storage     = lookup(each.value, "allocated_storage", var.allocated_storage)
  max_allocated_storage = lookup(each.value, "max_allocated_storage", var.max_allocated_storage)
  storage_type          = lookup(each.value, "storage_type", var.storage_type)
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  publicly_accessible    = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  availability_zone      = lookup(each.value, "availability_zone", null)
  port                   = 3306

  # Backup configuration
  backup_retention_period   = lookup(each.value, "backup_retention_period", 0)
  backup_window             = lookup(each.value, "backup_window", null)
  maintenance_window        = lookup(each.value, "maintenance_window", var.maintenance_window)
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-mysql-read-${each.key}-final-snapshot"

  # Performance Insights
  performance_insights_enabled          = lookup(each.value, "performance_insights_enabled", var.performance_insights_enabled)
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", var.performance_insights_retention_period)

  # Monitoring
  monitoring_interval = lookup(each.value, "monitoring_interval", var.monitoring_interval)
  monitoring_role_arn = var.monitoring_role_arn

  # Logging
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.mysql.name
  option_group_name    = length(var.option_group_options) > 0 ? aws_db_option_group.mysql[0].name : null

  # Deletion protection
  deletion_protection = lookup(each.value, "deletion_protection", var.deletion_protection)

  # Tags
  tags = merge(var.tags, {
    Name = "${var.environment}-mysql-read-${each.key}"
    Type = "read-replica"
  })

  depends_on = [
    aws_db_instance.mysql,
    aws_db_subnet_group.mysql,
    aws_security_group.mysql,
    aws_db_parameter_group.mysql
  ]
} 