# PostgreSQL RDS Module

This Terraform module creates a PostgreSQL RDS instance with comprehensive configuration options including security groups, parameter groups, read replicas, and automatic password management.

## Features

- **Random Password Generation**: Automatically generates secure passwords and stores them in AWS SSM Parameter Store
- **SSM Parameter Store Integration**: Passwords are encrypted and stored securely in SSM Parameter Store
- **Multi-AZ Support**: Configure high availability with Multi-AZ deployment
- **Read Replicas**: Support for multiple read replicas with individual configurations
- **Security Groups**: Configurable security groups with allowed CIDR blocks and security group IDs
- **Parameter Groups**: Custom PostgreSQL parameter configurations
- **Performance Insights**: Enable AWS Performance Insights for monitoring
- **Enhanced Monitoring**: Configure CloudWatch monitoring
- **Backup Management**: Configurable backup retention and maintenance windows
- **Encryption**: Storage encryption with optional KMS key support

## Usage

### Basic Usage with Random Password Generation

```hcl
module "postgres" {
  source = "../../modules/rds-postgres"

  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  allowed_cidr_blocks        = [module.vpc.vpc_cidr_block]

  # Database configuration
  database_name   = "myapp_dev"
  master_username = "postgres"
  generate_random_password = true  # This will generate a random password and store it in SSM

  # Engine configuration
  engine_version       = "15.4"
  engine_version_major = "15"
  instance_class       = "db.t3.micro"

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Advanced Usage with Custom Password

```hcl
module "postgres" {
  source = "../../modules/rds-postgres"

  environment        = "prod"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security configuration
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  allowed_cidr_blocks        = [module.vpc.vpc_cidr_block]

  # Database configuration
  database_name   = "myapp_prod"
  master_username = "postgres"
  generate_random_password = false
  master_password = var.custom_password  # Use custom password

  # Engine configuration
  engine_version       = "15.4"
  engine_version_major = "15"
  instance_class       = "db.r6g.large"

  # Storage configuration
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"
  storage_encrypted     = true

  # Backup configuration
  backup_retention_period = 35
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:03:00-sun:04:00"

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 30

  # Monitoring
  monitoring_interval = 60

  # Multi-AZ and Deletion Protection
  multi_az            = true
  deletion_protection = true

  # Read Replicas
  read_replicas = {
    "read-1" = {
      instance_class               = "db.r6g.large"
      availability_zone            = "us-west-2b"
      performance_insights_enabled = true
      deletion_protection          = true
      backup_retention_period      = 7
      monitoring_interval          = 60
    }
    "read-2" = {
      instance_class               = "db.r6g.large"
      availability_zone            = "us-west-2c"
      performance_insights_enabled = true
      deletion_protection          = true
      backup_retention_period      = 7
      monitoring_interval          = 60
    }
  }

  # Parameter Group
  parameter_group_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements,auto_explain"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]

  tags = {
    Environment = "prod"
    Project     = "myapp"
  }
}
```

## Password Management

### Random Password Generation (Recommended)

When `generate_random_password = true` (default):

1. **Automatic Generation**: The module generates a 32-character secure password
2. **SSM Parameter Store**: Password is automatically stored in SSM Parameter Store as a SecureString
3. **Parameter Path**: `/environment/rds/postgres/password` (e.g., `/dev/rds/postgres/password`)
4. **Encryption**: Password is encrypted using AWS KMS
5. **Access**: Use AWS CLI or SDK to retrieve the password:

```bash
# Get password from SSM Parameter Store
aws ssm get-parameter --name "/dev/rds/postgres/password" --with-decryption --query "Parameter.Value" --output text
```

### Custom Password

When `generate_random_password = false`:

1. **Manual Password**: Provide password via `master_password` variable
2. **No SSM Storage**: Password is not stored in SSM Parameter Store
3. **Security**: Ensure password is provided securely (e.g., via environment variables)

## Retrieving Database Credentials

### From Terraform Outputs

```hcl
# Get connection information
output "postgres_connection_info" {
  description = "PostgreSQL connection information"
  value       = module.postgres.connection_info
  sensitive   = true
}

# Get SSM parameter information
output "postgres_ssm_parameter_name" {
  description = "SSM Parameter Store name for PostgreSQL password"
  value       = module.postgres.ssm_parameter_name
}
```

### From AWS CLI

```bash
# Get the password
PASSWORD=$(aws ssm get-parameter --name "/dev/rds/postgres/password" --with-decryption --query "Parameter.Value" --output text)

# Get connection details from Terraform outputs
ENDPOINT=$(terraform output -raw postgres_endpoint)
PORT=$(terraform output -raw postgres_port)
DATABASE=$(terraform output -raw postgres_database_name)
USERNAME=$(terraform output -raw postgres_master_username)

# Connect to database
psql "host=$ENDPOINT port=$PORT dbname=$DATABASE user=$USERNAME password=$PASSWORD"
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| vpc_id | VPC ID where the RDS instance will be created | `string` | n/a | yes |
| private_subnet_ids | List of private subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| generate_random_password | Generate a random password and store it in SSM Parameter Store | `bool` | `true` | no |
| master_password | Master password for the database (required if generate_random_password is false) | `string` | `null` | no |
| master_username | Master username for the database | `string` | `"postgres"` | no |
| database_name | Name of the database to create | `string` | `"postgres"` | no |
| engine_version | PostgreSQL engine version | `string` | `"15.4"` | no |
| instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| allocated_storage | Allocated storage in GB | `number` | `20` | no |
| max_allocated_storage | Maximum allocated storage in GB | `number` | `100` | no |
| multi_az | Enable Multi-AZ deployment | `bool` | `false` | no |
| deletion_protection | Enable deletion protection | `bool` | `false` | no |
| performance_insights_enabled | Enable Performance Insights | `bool` | `false` | no |
| monitoring_interval | Monitoring interval in seconds | `number` | `0` | no |
| backup_retention_period | Backup retention period in days | `number` | `7` | no |
| read_replicas | Map of read replica configurations | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | RDS instance endpoint |
| port | RDS instance port |
| database_name | Database name |
| master_username | Master username |
| security_group_id | Security group ID for the RDS instance |
| ssm_parameter_name | SSM Parameter Store name for the password |
| ssm_parameter_arn | SSM Parameter Store ARN for the password |
| read_replica_endpoints | Map of read replica endpoints |
| connection_info | Database connection information (sensitive) |

## Security Best Practices

1. **Use Random Passwords**: Enable `generate_random_password = true` for automatic secure password generation
2. **SSM Parameter Store**: Passwords are encrypted and stored securely in SSM Parameter Store
3. **Security Groups**: Restrict access to specific security groups and CIDR blocks
4. **Encryption**: Enable storage encryption for all databases
5. **Private Subnets**: Deploy databases in private subnets only
6. **Deletion Protection**: Enable deletion protection for production environments
7. **Multi-AZ**: Use Multi-AZ for production high availability
8. **Monitoring**: Enable Performance Insights and enhanced monitoring for production

## Cost Optimization

1. **Development**: Use `db.t3.micro` instances with minimal storage
2. **Staging**: Use `db.t3.small` instances with moderate storage
3. **Production**: Use appropriate instance classes based on workload requirements
4. **Storage**: Use GP3 storage for better performance and cost
5. **Backup Retention**: Adjust backup retention based on environment needs
6. **Performance Insights**: Disable for development to save costs

## Examples

See the `examples/` directory for complete usage examples:

- `basic-postgres.tf` - Basic PostgreSQL setup with random password
- `production-postgres.tf` - Production-ready PostgreSQL with Multi-AZ and read replicas
- `custom-password-postgres.tf` - PostgreSQL with custom password management 