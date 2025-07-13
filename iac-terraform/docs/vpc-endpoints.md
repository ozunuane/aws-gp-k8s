# VPC Endpoints Configuration

This document describes the VPC endpoints configuration in the AWS GP K8s infrastructure and how they ensure secure, private communication with AWS services.

## Overview

VPC endpoints enable private communication between your VPC and AWS services without requiring an internet gateway, NAT device, VPN connection, or AWS Direct Connect connection. This infrastructure includes comprehensive VPC endpoint configuration for enhanced security, performance, and cost optimization.

## VPC Endpoints Included

### 1. S3 Gateway Endpoint (Primary Focus)

**Type**: Gateway Endpoint  
**Service**: Amazon S3  
**Purpose**: Routes ALL S3 traffic through the VPC endpoint

#### Key Features:
- **Universal Routing**: Associated with ALL route tables (public and private)
- **Comprehensive Policy**: Allows all S3 operations (`s3:*`)
- **Cost Optimization**: No data transfer charges for S3 access
- **Security**: Traffic never leaves AWS network

#### Use Cases:
- Container image pulls from ECR (which uses S3)
- Application data storage and retrieval
- Terraform state access
- Log storage and retrieval
- Backup storage

#### Configuration:
```hcl
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  
  # Associate with ALL route tables
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id
  )
  
  # Allow all S3 operations
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}
```

### 2. Interface Endpoints

#### EC2 Interface Endpoint
- **Purpose**: Private communication with EC2 API
- **Use Cases**: EKS cluster management, Karpenter node provisioning, EC2 instance management

#### ECR API Interface Endpoint
- **Purpose**: Container registry API operations
- **Use Cases**: Image listing, repository management, authentication

#### ECR DKR Interface Endpoint
- **Purpose**: Docker registry operations
- **Use Cases**: Image pulls, pushes, authentication

#### EKS Interface Endpoint
- **Purpose**: EKS API operations
- **Use Cases**: Cluster management, node group operations

#### CloudWatch Logs Interface Endpoint
- **Purpose**: Application logging
- **Use Cases**: Container logs, application metrics, monitoring

#### Secrets Manager Interface Endpoint
- **Purpose**: Secret management
- **Use Cases**: Application secrets, database credentials, API keys

#### Systems Manager (SSM) Interface Endpoint
- **Purpose**: SSM operations
- **Use Cases**: Session Manager, Run Command, Parameter Store

#### SSM Messages Interface Endpoint
- **Purpose**: SSM messaging
- **Use Cases**: SSM agent communication, Systems Manager messaging

#### EC2 Messages Interface Endpoint
- **Purpose**: EC2 messaging
- **Use Cases**: EC2 instance metadata, messaging services

## Configuration Options

### Enable/Disable VPC Endpoints

```hcl
variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}
```

### Granular Control

```hcl
variable "vpc_endpoints_config" {
  description = "Configuration for which VPC endpoints to enable"
  type = object({
    s3             = bool
    ec2            = bool
    ecr_api        = bool
    ecr_dkr        = bool
    eks            = bool
    logs           = bool
    secretsmanager = bool
    ssm            = bool
    ssm_messages   = bool
    ec2_messages   = bool
  })
  default = {
    s3             = true
    ec2            = true
    ecr_api        = true
    ecr_dkr        = true
    eks            = true
    logs           = true
    secretsmanager = true
    ssm            = true
    ssm_messages   = true
    ec2_messages   = true
  }
}
```

## Security Configuration

### Security Group for Interface Endpoints

```hcl
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
}
```

## Benefits

### 1. Security
- **Private Communication**: All traffic stays within AWS network
- **Reduced Attack Surface**: No internet exposure for AWS service access
- **Compliance**: Helps meet security requirements for private networks

### 2. Performance
- **Lower Latency**: Direct connection to AWS services
- **Higher Bandwidth**: Better throughput than internet connections
- **Consistent Performance**: Avoids internet congestion

### 3. Cost Optimization
- **No NAT Gateway Costs**: Reduces or eliminates NAT gateway usage
- **No Data Transfer Charges**: Free traffic between VPC and AWS services
- **Reduced Egress Costs**: Avoids internet egress charges

### 4. Reliability
- **High Availability**: AWS-managed endpoints with 99.99% SLA
- **Automatic Scaling**: Handles traffic spikes automatically
- **Fault Tolerance**: Built-in redundancy and failover

## Environment-Specific Configuration

### Development Environment
```hcl
enable_vpc_endpoints = true
vpc_endpoints_config = {
  s3             = true   # Always enabled for S3 access
  ec2            = true   # For EKS and node management
  ecr_api        = true   # For container registry
  ecr_dkr        = true   # For Docker operations
  eks            = true   # For EKS API
  logs           = false  # Optional for dev
  secretsmanager = false  # Optional for dev
  ssm            = false  # Optional for dev
  ssm_messages   = false  # Optional for dev
  ec2_messages   = false  # Optional for dev
}
```

### Staging Environment
```hcl
enable_vpc_endpoints = true
vpc_endpoints_config = {
  s3             = true
  ec2            = true
  ecr_api        = true
  ecr_dkr        = true
  eks            = true
  logs           = true   # Enable for monitoring
  secretsmanager = true   # Enable for secrets
  ssm            = true   # Enable for management
  ssm_messages   = true
  ec2_messages   = true
}
```

### Production Environment
```hcl
enable_vpc_endpoints = true
vpc_endpoints_config = {
  s3             = true
  ec2            = true
  ecr_api        = true
  ecr_dkr        = true
  eks            = true
  logs           = true
  secretsmanager = true
  ssm            = true
  ssm_messages   = true
  ec2_messages   = true
}
```

## Monitoring and Troubleshooting

### Check VPC Endpoint Status
```bash
# List all VPC endpoints
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Check specific endpoint
aws ec2 describe-vpc-endpoints --vpc-endpoint-ids vpce-xxxxxxxxx
```

### Verify S3 Routing
```bash
# Test S3 access through VPC endpoint
aws s3 ls --endpoint-url https://s3.us-west-2.amazonaws.com

# Check route table associations
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"
```

### Common Issues and Solutions

#### Issue: S3 Access Failing
**Solution**: Verify VPC endpoint is associated with all route tables
```bash
aws ec2 describe-route-tables --route-table-ids rtb-xxxxxxxxx
```

#### Issue: Interface Endpoint Not Responding
**Solution**: Check security group rules
```bash
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx
```

#### Issue: DNS Resolution Problems
**Solution**: Verify private DNS is enabled
```bash
aws ec2 describe-vpc-endpoints --vpc-endpoint-ids vpce-xxxxxxxxx --query 'VpcEndpoints[0].PrivateDnsEnabled'
```

## Best Practices

### 1. Security
- Use least-privilege policies for VPC endpoints
- Regularly audit VPC endpoint policies
- Monitor VPC endpoint access logs

### 2. Performance
- Place interface endpoints in private subnets
- Use multiple availability zones for high availability
- Monitor endpoint performance metrics

### 3. Cost Management
- Enable only necessary endpoints per environment
- Monitor VPC endpoint usage and costs
- Use gateway endpoints for S3 and DynamoDB when possible

### 4. Operations
- Document endpoint configurations
- Test endpoint connectivity regularly
- Have fallback plans for endpoint failures

## Integration with EKS

VPC endpoints are particularly important for EKS clusters:

### EKS Control Plane
- Private communication with EKS API
- Secure cluster management operations

### Container Operations
- Private image pulls from ECR
- Secure access to application secrets
- Private logging to CloudWatch

### Node Management
- Karpenter can provision nodes without internet access
- SSM operations for node management
- Secure communication with AWS services

## Outputs

The VPC module provides comprehensive outputs for VPC endpoints:

```hcl
output "s3_endpoint_id" {
  description = "ID of the S3 VPC Gateway Endpoint"
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "vpc_endpoints" {
  description = "Map of all VPC endpoints created"
  value = {
    s3 = try({
      id   = aws_vpc_endpoint.s3[0].id
      type = "Gateway"
      service_name = aws_vpc_endpoint.s3[0].service_name
    }, null)
    # ... other endpoints
  }
}
```

## References

- [AWS VPC Endpoints Documentation](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- [S3 Gateway Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html)
- [Interface Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/interface-endpoints.html)
- [EKS VPC Endpoints](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) 