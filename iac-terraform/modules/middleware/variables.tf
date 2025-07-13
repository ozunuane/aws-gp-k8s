# Middleware Module - Variables

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where middleware services will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# Redis Variables
variable "enable_redis" {
  description = "Enable Redis ElastiCache cluster"
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_parameter_group_name" {
  description = "Redis parameter group name"
  type        = string
  default     = "default.redis7"
}

variable "redis_num_cache_clusters" {
  description = "Number of cache clusters"
  type        = number
  default     = 2
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "redis_auth_token" {
  description = "Redis auth token"
  type        = string
  default     = null
  sensitive   = true
}

variable "redis_maintenance_window" {
  description = "Redis maintenance window"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "redis_snapshot_retention_limit" {
  description = "Redis snapshot retention limit"
  type        = number
  default     = 5
}

variable "redis_snapshot_window" {
  description = "Redis snapshot window"
  type        = string
  default     = "03:00-05:00"
}

variable "redis_automatic_failover_enabled" {
  description = "Enable automatic failover for Redis"
  type        = bool
  default     = true
}

variable "redis_multi_az_enabled" {
  description = "Enable multi-AZ for Redis"
  type        = bool
  default     = true
}

# Kafka Variables
variable "enable_kafka" {
  description = "Enable Amazon MSK (Kafka) cluster"
  type        = bool
  default     = false
}

variable "kafka_version" {
  description = "Kafka version"
  type        = string
  default     = "2.8.1"
}

variable "kafka_number_of_broker_nodes" {
  description = "Number of broker nodes"
  type        = number
  default     = 3
}

variable "kafka_instance_type" {
  description = "Kafka instance type"
  type        = string
  default     = "kafka.t3.small"
}

variable "kafka_ebs_volume_size" {
  description = "EBS volume size for Kafka brokers"
  type        = number
  default     = 100
}

variable "kafka_kms_key_id" {
  description = "KMS key ID for Kafka encryption"
  type        = string
  default     = null
}

variable "kafka_certificate_authority_arns" {
  description = "List of certificate authority ARNs for Kafka client authentication"
  type        = list(string)
  default     = []
}

variable "kafka_cloudwatch_logs_enabled" {
  description = "Enable CloudWatch logs for Kafka"
  type        = bool
  default     = true
}

variable "kafka_firehose_logs_enabled" {
  description = "Enable Firehose logs for Kafka"
  type        = bool
  default     = false
}

variable "kafka_firehose_delivery_stream" {
  description = "Firehose delivery stream for Kafka logs"
  type        = string
  default     = null
}

variable "kafka_s3_logs_enabled" {
  description = "Enable S3 logs for Kafka"
  type        = bool
  default     = false
}

variable "kafka_s3_logs_bucket" {
  description = "S3 bucket for Kafka logs"
  type        = string
  default     = null
}

variable "kafka_s3_logs_prefix" {
  description = "S3 prefix for Kafka logs"
  type        = string
  default     = null
}

variable "kafka_log_retention_days" {
  description = "CloudWatch log retention days for Kafka"
  type        = number
  default     = 14
}

# RabbitMQ Variables
variable "enable_rabbitmq" {
  description = "Enable Amazon MQ (RabbitMQ) broker"
  type        = bool
  default     = false
}

variable "rabbitmq_engine_version" {
  description = "RabbitMQ engine version"
  type        = string
  default     = "3.10.20"
}

variable "rabbitmq_instance_type" {
  description = "RabbitMQ instance type"
  type        = string
  default     = "mq.t3.micro"
}

variable "rabbitmq_deployment_mode" {
  description = "RabbitMQ deployment mode"
  type        = string
  default     = "SINGLE_INSTANCE"
}

variable "rabbitmq_username" {
  description = "RabbitMQ username"
  type        = string
  default     = "admin"
}

variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}

variable "rabbitmq_auto_minor_version_upgrade" {
  description = "Enable auto minor version upgrade for RabbitMQ"
  type        = bool
  default     = true
}

variable "rabbitmq_maintenance_day_of_week" {
  description = "RabbitMQ maintenance day of week"
  type        = string
  default     = "SUNDAY"
}

variable "rabbitmq_maintenance_time_of_day" {
  description = "RabbitMQ maintenance time of day"
  type        = string
  default     = "03:00"
}

variable "rabbitmq_maintenance_time_zone" {
  description = "RabbitMQ maintenance time zone"
  type        = string
  default     = "UTC"
}

variable "rabbitmq_general_logs_enabled" {
  description = "Enable general logs for RabbitMQ"
  type        = bool
  default     = true
}

# DocumentDB Variables
variable "enable_documentdb" {
  description = "Enable Amazon DocumentDB cluster"
  type        = bool
  default     = false
}

variable "documentdb_engine_version" {
  description = "DocumentDB engine version"
  type        = string
  default     = "4.0.0"
}

variable "documentdb_master_username" {
  description = "DocumentDB master username"
  type        = string
  default     = "admin"
}

variable "documentdb_master_password" {
  description = "DocumentDB master password"
  type        = string
  sensitive   = true
}

variable "documentdb_backup_retention_period" {
  description = "DocumentDB backup retention period"
  type        = number
  default     = 7
}

variable "documentdb_preferred_backup_window" {
  description = "DocumentDB preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "documentdb_skip_final_snapshot" {
  description = "Skip final snapshot for DocumentDB"
  type        = bool
  default     = true
}

variable "documentdb_storage_encrypted" {
  description = "Enable storage encryption for DocumentDB"
  type        = bool
  default     = true
}

variable "documentdb_kms_key_id" {
  description = "KMS key ID for DocumentDB encryption"
  type        = string
  default     = null
}

variable "documentdb_instance_count" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 2
}

variable "documentdb_instance_class" {
  description = "DocumentDB instance class"
  type        = string
  default     = "db.t3.medium"
} 