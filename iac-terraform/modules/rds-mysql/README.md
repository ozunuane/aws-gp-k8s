# MySQL RDS Module

This module creates a MySQL RDS instance with comprehensive security, monitoring, and backup configurations.

## Features

- **Security**: VPC-based deployment with security groups and encryption
- **Monitoring**: CloudWatch monitoring and Performance Insights
- **Backup**: Automated backups with configurable retention
- **High Availability**: Multi-AZ support and read replicas
- **Logging**: CloudWatch log exports for MySQL logs (error, general, slow_query)
- **Parameter Groups**: Custom MySQL parameter configurations
- **Option Groups**: Support for MySQL extensions and options

## Usage

```hcl
module "mysql" {
  source = "../../modules/rds-mysql"

  environment = "dev"
  vpc_id      = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  allowed_cidr_blocks = ["10.0.0.0/16"]

  # Database configuration
  database_name  = "myapp"
  master_username = "admin"
  master_password = var.mysql_password

  # Engine configuration
  engine_version = "8.0.35"
  instance_class = "db.t3.micro"

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Performance Insights
  performance_insights_enabled = true

  # Monitoring
  monitoring_interval = 60

  # Parameter Group
  parameter_group_parameters = [
    {
      name  = "slow_query_log"
      value = "1"
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| vpc_id | VPC ID where the RDS instance will be created | `string` | n/a | yes |
| private_subnet_ids | List of private subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| allowed_security_group_ids | List of security group IDs allowed to connect to the database | `list(string)` | `[]` | no |
| allowed_cidr_blocks | List of CIDR blocks allowed to connect to the database | `list(string)` | `[]` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| engine_version | MySQL engine version | `string` | `"8.0.35"` | no |
| engine_version_major | Major version of MySQL engine | `string` | `"8.0"` | no |
| instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| allocated_storage | Allocated storage in GB | `number` | `20` | no |
| max_allocated_storage | Maximum allocated storage in GB | `number` | `100` | no |
| storage_type | Storage type (gp2, gp3, io1) | `string` | `"gp3"` | no |
| storage_encrypted | Enable storage encryption | `bool` | `true` | no |
| kms_key_id | KMS key ID for encryption | `string` | `null` | no |
| publicly_accessible | Make the database publicly accessible | `bool` | `false` | no |
| availability_zone | Availability zone for the database | `string` | `null` | no |
| database_name | Name of the database to create | `string` | `"mysql"` | no |
| master_username | Master username for the database | `string` | `"admin"` | no |
| master_password | Master password for the database | `string` | n/a | yes |
| backup_retention_period | Backup retention period in days | `number` | `7` | no |
| backup_window | Backup window | `string` | `"03:00-04:00"` | no |
| maintenance_window | Maintenance window | `string` | `"sun:04:00-sun:05:00"` | no |
| copy_tags_to_snapshot | Copy tags to snapshots | `bool` | `true` | no |
| skip_final_snapshot | Skip final snapshot when destroying | `bool` | `false` | no |
| performance_insights_enabled | Enable Performance Insights | `bool` | `false` | no |
| performance_insights_retention_period | Performance Insights retention period in days | `number` | `7` | no |
| monitoring_interval | Monitoring interval in seconds | `number` | `0` | no |
| monitoring_role_arn | IAM role ARN for monitoring | `string` | `null` | no |
| enabled_cloudwatch_logs_exports | List of log types to export to CloudWatch | `list(string)` | `["error", "general", "slow_query"]` | no |
| parameter_group_parameters | List of parameter group parameters | `list(object)` | `[]` | no |
| option_group_options | List of option group options | `list(object)` | `[]` | no |
| multi_az | Enable Multi-AZ deployment | `bool` | `false` | no |
| deletion_protection | Enable deletion protection | `bool` | `false` | no |
| read_replicas | Map of read replica configurations | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | RDS instance ID |
| instance_arn | RDS instance ARN |
| instance_endpoint | RDS instance endpoint |
| instance_address | RDS instance address |
| instance_port | RDS instance port |
| instance_status | RDS instance status |
| instance_availability_zone | RDS instance availability zone |
| instance_multi_az | Whether the RDS instance is Multi-AZ |
| security_group_id | Security group ID for the RDS instance |
| security_group_arn | Security group ARN for the RDS instance |
| subnet_group_id | DB subnet group ID |
| subnet_group_arn | DB subnet group ARN |
| subnet_group_name | DB subnet group name |
| parameter_group_id | DB parameter group ID |
| parameter_group_arn | DB parameter group ARN |
| parameter_group_name | DB parameter group name |
| option_group_id | DB option group ID |
| option_group_arn | DB option group ARN |
| option_group_name | DB option group name |
| read_replica_endpoints | Map of read replica endpoints |
| read_replica_ids | List of read replica instance IDs |
| read_replica_arns | List of read replica instance ARNs |
| connection_info | Database connection information (sensitive) |
| latest_restorable_time | Latest restorable time for the RDS instance |
| backup_retention_period | Backup retention period in days |
| backup_window | Backup window |
| maintenance_window | Maintenance window |
| performance_insights_enabled | Whether Performance Insights is enabled |
| performance_insights_retention_period | Performance Insights retention period in days |
| monitoring_interval | Monitoring interval in seconds |
| monitoring_role_arn | IAM role ARN for monitoring |
| allocated_storage | Allocated storage in GB |
| max_allocated_storage | Maximum allocated storage in GB |
| storage_type | Storage type |
| storage_encrypted | Whether storage is encrypted |
| engine | Database engine |
| engine_version | Database engine version |
| instance_class | RDS instance class |
| publicly_accessible | Whether the database is publicly accessible |
| vpc_security_group_ids | List of VPC security group IDs |
| db_subnet_group_name | DB subnet group name |
| tags | Tags applied to the RDS instance |

## Security Features

### Network Security
- Deployed in private subnets
- Security groups with restricted access
- VPC-only access (not publicly accessible by default)
- Support for CIDR blocks and security group access

### Data Security
- Storage encryption enabled by default
- KMS key support for encryption
- SSL/TLS encryption in transit
- IAM database authentication support

### Access Control
- Configurable master username and password
- Parameter group for fine-grained control
- Option groups for extensions and features

## Monitoring and Logging

### CloudWatch Monitoring
- Enhanced monitoring with configurable intervals
- Performance Insights for query analysis
- CloudWatch log exports for MySQL logs (error, general, slow_query)

### Backup and Recovery
- Automated backups with configurable retention
- Point-in-time recovery
- Manual snapshots support
- Cross-region backup copying

## High Availability

### Multi-AZ Deployment
- Automatic failover to standby instance
- Synchronous replication
- Enhanced availability and durability

### Read Replicas
- Asynchronous replication
- Load distribution for read workloads
- Cross-region replication support
- Automatic promotion to primary if needed

## Parameter Groups

Common MySQL parameters you might want to configure:

```hcl
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
  },
  {
    name  = "innodb_log_file_size"
    value = "268435456"
  },
  {
    name  = "max_connections"
    value = "1000"
  },
  {
    name  = "wait_timeout"
    value = "28800"
  },
  {
    name  = "interactive_timeout"
    value = "28800"
  }
]
```

## Option Groups

MySQL option groups for extensions:

```hcl
option_group_options = [
  {
    option_name = "MARIADB_AUDIT_PLUGIN"
  },
  {
    option_name = "MYSQL_NATIVE_PASSWORD"
  }
]
```

## Read Replicas

Configure read replicas for load distribution:

```hcl
read_replicas = {
  "read-1" = {
    instance_class = "db.t3.micro"
    availability_zone = "us-west-2b"
    performance_insights_enabled = true
    deletion_protection = false
  },
  "read-2" = {
    instance_class = "db.t3.small"
    availability_zone = "us-west-2c"
    performance_insights_enabled = true
    deletion_protection = false
  }
}
```

## Environment-Specific Configurations

### Development
```hcl
instance_class = "db.t3.micro"
allocated_storage = 20
multi_az = false
deletion_protection = false
performance_insights_enabled = false
```

### Staging
```hcl
instance_class = "db.t3.small"
allocated_storage = 50
multi_az = false
deletion_protection = true
performance_insights_enabled = true
```

### Production
```hcl
instance_class = "db.r5.large"
allocated_storage = 100
multi_az = true
deletion_protection = true
performance_insights_enabled = true
backup_retention_period = 30
```

## Best Practices

1. **Security**: Always use private subnets and security groups
2. **Encryption**: Enable storage encryption for all environments
3. **Backup**: Configure appropriate backup retention periods
4. **Monitoring**: Enable Performance Insights for production
5. **Multi-AZ**: Use Multi-AZ for production workloads
6. **Parameter Groups**: Use custom parameter groups for optimization
7. **Tags**: Apply consistent tagging for cost management
8. **Deletion Protection**: Enable for production environments
9. **Slow Query Logging**: Enable for performance monitoring
10. **Connection Pooling**: Configure appropriate connection limits

## Troubleshooting

### Common Issues

1. **Connection Timeouts**: Check security group rules and subnet configurations
2. **Performance Issues**: Review Performance Insights and parameter group settings
3. **Backup Failures**: Verify IAM permissions and storage space
4. **Monitoring Issues**: Check IAM role permissions for CloudWatch
5. **Slow Queries**: Enable slow query logging and review parameter group settings

### Useful Commands

```bash
# Check RDS instance status
aws rds describe-db-instances --db-instance-identifier dev-mysql

# View CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix "/aws/rds/instance"

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

# Connect to MySQL instance
mysql -h dev-mysql.xxxxx.us-west-2.rds.amazonaws.com -u admin -p
```

## Cost Optimization

1. **Instance Sizing**: Right-size instances based on workload
2. **Storage**: Use gp3 storage for better performance/cost ratio
3. **Multi-AZ**: Only enable when needed for high availability
4. **Read Replicas**: Use for read-heavy workloads
5. **Backup Retention**: Optimize retention periods per environment
6. **Performance Insights**: Disable for non-production if not needed
7. **Parameter Tuning**: Optimize MySQL parameters for your workload

## MySQL-Specific Considerations

### Character Sets and Collations
- Default: utf8mb4 with utf8mb4_general_ci collation
- Supports full Unicode including emojis
- Configure via parameter group if needed

### Storage Engines
- InnoDB is the default and recommended storage engine
- Supports ACID transactions and foreign keys
- Configure via parameter group if needed

### Replication
- Binary log format: ROW (recommended for consistency)
- GTID replication for better failover handling
- Configure via parameter group if needed 