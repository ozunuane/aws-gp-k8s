# Middleware Module - Outputs

# Redis Outputs
output "redis_replication_group_id" {
  description = "Redis replication group ID"
  value       = var.enable_redis ? aws_elasticache_replication_group.redis[0].id : null
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  value       = var.enable_redis ? aws_elasticache_replication_group.redis[0].configuration_endpoint_address : null
}

output "redis_port" {
  description = "Redis port"
  value       = var.enable_redis ? aws_elasticache_replication_group.redis[0].port : null
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = var.enable_redis ? aws_security_group.redis[0].id : null
}

# Kafka Outputs
output "kafka_cluster_arn" {
  description = "Kafka cluster ARN"
  value       = var.enable_kafka ? aws_msk_cluster.kafka[0].arn : null
}

output "kafka_cluster_name" {
  description = "Kafka cluster name"
  value       = var.enable_kafka ? aws_msk_cluster.kafka[0].cluster_name : null
}

output "kafka_bootstrap_brokers" {
  description = "Kafka bootstrap brokers"
  value       = var.enable_kafka ? aws_msk_cluster.kafka[0].bootstrap_brokers : null
}

output "kafka_bootstrap_brokers_tls" {
  description = "Kafka bootstrap brokers TLS"
  value       = var.enable_kafka ? aws_msk_cluster.kafka[0].bootstrap_brokers_tls : null
}

output "kafka_zookeeper_connect_string" {
  description = "Kafka Zookeeper connect string"
  value       = var.enable_kafka ? aws_msk_cluster.kafka[0].zookeeper_connect_string : null
}

output "kafka_security_group_id" {
  description = "Kafka security group ID"
  value       = var.enable_kafka ? aws_security_group.kafka[0].id : null
}

# RabbitMQ Outputs
output "rabbitmq_broker_id" {
  description = "RabbitMQ broker ID"
  value       = var.enable_rabbitmq ? aws_mq_broker.rabbitmq[0].id : null
}

output "rabbitmq_broker_arn" {
  description = "RabbitMQ broker ARN"
  value       = var.enable_rabbitmq ? aws_mq_broker.rabbitmq[0].arn : null
}

output "rabbitmq_console_url" {
  description = "RabbitMQ console URL"
  value       = var.enable_rabbitmq ? aws_mq_broker.rabbitmq[0].instances[0].console_url : null
}

output "rabbitmq_endpoints" {
  description = "RabbitMQ endpoints"
  value       = var.enable_rabbitmq ? aws_mq_broker.rabbitmq[0].instances[0].endpoints : null
}

output "rabbitmq_security_group_id" {
  description = "RabbitMQ security group ID"
  value       = var.enable_rabbitmq ? aws_security_group.rabbitmq[0].id : null
}

# DocumentDB Outputs
output "documentdb_cluster_id" {
  description = "DocumentDB cluster ID"
  value       = var.enable_documentdb ? aws_docdb_cluster.docdb[0].id : null
}

output "documentdb_cluster_arn" {
  description = "DocumentDB cluster ARN"
  value       = var.enable_documentdb ? aws_docdb_cluster.docdb[0].arn : null
}

output "documentdb_endpoint" {
  description = "DocumentDB endpoint"
  value       = var.enable_documentdb ? aws_docdb_cluster.docdb[0].endpoint : null
}

output "documentdb_reader_endpoint" {
  description = "DocumentDB reader endpoint"
  value       = var.enable_documentdb ? aws_docdb_cluster.docdb[0].reader_endpoint : null
}

output "documentdb_port" {
  description = "DocumentDB port"
  value       = var.enable_documentdb ? aws_docdb_cluster.docdb[0].port : null
}

output "documentdb_security_group_id" {
  description = "DocumentDB security group ID"
  value       = var.enable_documentdb ? aws_security_group.docdb[0].id : null
} 