# Middleware Module - Main Configuration
# Creates managed services like Redis, Kafka, and RabbitMQ

# ElastiCache Redis Cluster
resource "aws_elasticache_subnet_group" "redis" {
  count = var.enable_redis ? 1 : 0

  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.environment}-redis-subnet-group"
  })
}

resource "aws_security_group" "redis" {
  count = var.enable_redis ? 1 : 0

  name_prefix = "${var.environment}-redis-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-redis-sg"
  })
}

resource "aws_elasticache_replication_group" "redis" {
  count = var.enable_redis ? 1 : 0

  replication_group_id = "${var.environment}-redis"
  description          = "Redis cluster for ${var.environment}"

  node_type            = var.redis_node_type
  port                 = 6379
  parameter_group_name = var.redis_parameter_group_name
  num_cache_clusters   = var.redis_num_cache_clusters

  engine_version             = var.redis_engine_version
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.redis_auth_token

  subnet_group_name  = aws_elasticache_subnet_group.redis[0].name
  security_group_ids = [aws_security_group.redis[0].id]

  maintenance_window       = var.redis_maintenance_window
  snapshot_retention_limit = var.redis_snapshot_retention_limit
  snapshot_window          = var.redis_snapshot_window

  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled           = var.redis_multi_az_enabled

  tags = merge(var.tags, {
    Name = "${var.environment}-redis"
  })
}

# Amazon MSK (Managed Streaming for Kafka)
resource "aws_msk_configuration" "kafka" {
  count = var.enable_kafka ? 1 : 0

  kafka_versions = [var.kafka_version]
  name           = "${var.environment}-kafka-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable=false
default.replication.factor=3
min.insync.replicas=2
num.partitions=3
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=false
PROPERTIES
}

resource "aws_security_group" "kafka" {
  count = var.enable_kafka ? 1 : 0

  name_prefix = "${var.environment}-kafka-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-kafka-sg"
  })
}

resource "aws_msk_cluster" "kafka" {
  count = var.enable_kafka ? 1 : 0

  cluster_name           = "${var.environment}-kafka"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    ebs_volume_size = var.kafka_ebs_volume_size
    client_subnets  = var.private_subnet_ids
    security_groups = [aws_security_group.kafka[0].id]
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka[0].arn
    revision = aws_msk_configuration.kafka[0].latest_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_id = var.kafka_kms_key_id
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    tls {
      certificate_authority_arns = var.kafka_certificate_authority_arns
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.kafka_cloudwatch_logs_enabled
        log_group = var.kafka_cloudwatch_logs_enabled ? aws_cloudwatch_log_group.kafka[0].name : null
      }
      firehose {
        enabled         = var.kafka_firehose_logs_enabled
        delivery_stream = var.kafka_firehose_logs_enabled ? var.kafka_firehose_delivery_stream : null
      }
      s3 {
        enabled = var.kafka_s3_logs_enabled
        bucket  = var.kafka_s3_logs_enabled ? var.kafka_s3_logs_bucket : null
        prefix  = var.kafka_s3_logs_enabled ? var.kafka_s3_logs_prefix : null
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-kafka"
  })
}

resource "aws_cloudwatch_log_group" "kafka" {
  count = var.enable_kafka && var.kafka_cloudwatch_logs_enabled ? 1 : 0

  name              = "/aws/msk/${var.environment}-kafka"
  retention_in_days = var.kafka_log_retention_days

  tags = merge(var.tags, {
    Name = "${var.environment}-kafka-logs"
  })
}

# Amazon MQ (RabbitMQ)
resource "aws_security_group" "rabbitmq" {
  count = var.enable_rabbitmq ? 1 : 0

  name_prefix = "${var.environment}-rabbitmq-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-rabbitmq-sg"
  })
}

resource "aws_mq_broker" "rabbitmq" {
  count = var.enable_rabbitmq ? 1 : 0

  broker_name        = "${var.environment}-rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = var.rabbitmq_engine_version
  host_instance_type = var.rabbitmq_instance_type
  deployment_mode    = var.rabbitmq_deployment_mode

  user {
    username = var.rabbitmq_username
    password = var.rabbitmq_password
  }

  subnet_ids          = var.rabbitmq_deployment_mode == "CLUSTER_MULTI_AZ" ? var.private_subnet_ids : [var.private_subnet_ids[0]]
  security_groups     = [aws_security_group.rabbitmq[0].id]
  publicly_accessible = false

  auto_minor_version_upgrade = var.rabbitmq_auto_minor_version_upgrade
  maintenance_window_start_time {
    day_of_week = var.rabbitmq_maintenance_day_of_week
    time_of_day = var.rabbitmq_maintenance_time_of_day
    time_zone   = var.rabbitmq_maintenance_time_zone
  }

  logs {
    general = var.rabbitmq_general_logs_enabled
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-rabbitmq"
  })
}

# Amazon DocumentDB (MongoDB-compatible)
resource "aws_docdb_subnet_group" "docdb" {
  count = var.enable_documentdb ? 1 : 0

  name       = "${var.environment}-docdb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.environment}-docdb-subnet-group"
  })
}

resource "aws_security_group" "docdb" {
  count = var.enable_documentdb ? 1 : 0

  name_prefix = "${var.environment}-docdb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-docdb-sg"
  })
}

resource "aws_docdb_cluster" "docdb" {
  count = var.enable_documentdb ? 1 : 0

  cluster_identifier      = "${var.environment}-docdb"
  engine                  = "docdb"
  engine_version          = var.documentdb_engine_version
  master_username         = var.documentdb_master_username
  master_password         = var.documentdb_master_password
  backup_retention_period = var.documentdb_backup_retention_period
  preferred_backup_window = var.documentdb_preferred_backup_window
  skip_final_snapshot     = var.documentdb_skip_final_snapshot

  db_subnet_group_name   = aws_docdb_subnet_group.docdb[0].name
  vpc_security_group_ids = [aws_security_group.docdb[0].id]

  storage_encrypted = var.documentdb_storage_encrypted
  kms_key_id        = var.documentdb_kms_key_id

  tags = merge(var.tags, {
    Name = "${var.environment}-docdb"
  })
}

resource "aws_docdb_cluster_instance" "docdb" {
  count = var.enable_documentdb ? var.documentdb_instance_count : 0

  identifier         = "${var.environment}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb[0].id
  instance_class     = var.documentdb_instance_class

  tags = merge(var.tags, {
    Name = "${var.environment}-docdb-${count.index}"
  })
} 