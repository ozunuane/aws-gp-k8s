# PostgreSQL RDS Module - Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Engine Configuration
variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "engine_version_major" {
  description = "Major version of PostgreSQL engine (e.g., 15 for 15.4)"
  type        = string
  default     = "15"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

# Storage Configuration
variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# Network Configuration
variable "publicly_accessible" {
  description = "Make the database publicly accessible"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for the database"
  type        = string
  default     = null
}

# Database Configuration
variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "postgres"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "generate_random_password" {
  description = "Generate a random password and store it in SSM Parameter Store"
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Master password for the database (required if generate_random_password is false)"
  type        = string
  sensitive   = true
  default     = null
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window (e.g., 03:00-04:00)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window (e.g., sun:04:00-sun:05:00)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = false
}

# Performance Insights
variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

# Monitoring
variable "monitoring_interval" {
  description = "Monitoring interval in seconds"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for monitoring"
  type        = string
  default     = null
}

# Logging
variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql"]
}

# Parameter Group
variable "parameter_group_parameters" {
  description = "List of parameter group parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Option Group
variable "option_group_options" {
  description = "List of option group options"
  type = list(object({
    option_name                    = string
    port                           = optional(number)
    version                        = optional(string)
    vpc_security_group_memberships = optional(list(string))
    db_security_group_memberships  = optional(list(string))
  }))
  default = []
}

# Multi-AZ
variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

# Deletion Protection
variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# Read Replicas
variable "read_replicas" {
  description = "Map of read replica configurations"
  type = map(object({
    instance_class                        = string
    allocated_storage                     = optional(number)
    max_allocated_storage                 = optional(number)
    storage_type                          = optional(string)
    publicly_accessible                   = optional(bool)
    availability_zone                     = optional(string)
    backup_retention_period               = optional(number)
    backup_window                         = optional(string)
    maintenance_window                    = optional(string)
    performance_insights_enabled          = optional(bool)
    performance_insights_retention_period = optional(number)
    monitoring_interval                   = optional(number)
    deletion_protection                   = optional(bool)
  }))
  default = {}
} 