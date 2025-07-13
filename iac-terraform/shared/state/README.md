# Terraform State Management

This directory contains documentation and configuration for managing Terraform state across environments using modern best practices.

## State Backend Configuration

Each environment uses a separate S3 bucket for state management with built-in locking capabilities:

### Development Environment
- **S3 Bucket**: `terraform-state-dev-aws-gp-k8s-{account-id}`
- **Key**: `dev/terraform.tfstate`
- **Region**: `us-west-2` (configurable)

### Staging Environment
- **S3 Bucket**: `terraform-state-staging-aws-gp-k8s-{account-id}`
- **Key**: `staging/terraform.tfstate`
- **Region**: `us-west-2` (configurable)

### Production Environment
- **S3 Bucket**: `terraform-state-prod-aws-gp-k8s-{account-id}`
- **Key**: `prod/terraform.tfstate`
- **Region**: `us-west-2` (configurable)

## Prerequisites

Before running Terraform, you need to create the S3 buckets for state management with proper security configurations.

### Create S3 Buckets with Security Best Practices

```bash
# Replace {account-id} with your AWS account ID
ACCOUNT_ID="your-account-id"
REGION="us-west-2"

# Create buckets
aws s3 mb s3://terraform-state-dev-aws-gp-k8s-${ACCOUNT_ID} --region ${REGION}
aws s3 mb s3://terraform-state-staging-aws-gp-k8s-${ACCOUNT_ID} --region ${REGION}
aws s3 mb s3://terraform-state-prod-aws-gp-k8s-${ACCOUNT_ID} --region ${REGION}

# Enable versioning for state recovery
aws s3api put-bucket-versioning \
  --bucket terraform-state-dev-aws-gp-k8s-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-versioning \
  --bucket terraform-state-staging-aws-gp-k8s-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-versioning \
  --bucket terraform-state-prod-aws-gp-k8s-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-dev-aws-gp-k8s-${ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        },
        "BucketKeyEnabled": true
      }
    ]
  }'

aws s3api put-bucket-encryption \
  --bucket terraform-state-staging-aws-gp-k8s-${ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        },
        "BucketKeyEnabled": true
      }
    ]
  }'

aws s3api put-bucket-encryption \
  --bucket terraform-state-prod-aws-gp-k8s-${ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        },
        "BucketKeyEnabled": true
      }
    ]
  }'

# Block all public access
aws s3api put-public-access-block \
  --bucket terraform-state-dev-aws-gp-k8s-${ACCOUNT_ID} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-public-access-block \
  --bucket terraform-state-staging-aws-gp-k8s-${ACCOUNT_ID} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-public-access-block \
  --bucket terraform-state-prod-aws-gp-k8s-${ACCOUNT_ID} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Enable access logging (optional but recommended)
aws s3api put-bucket-logging \
  --bucket terraform-state-dev-aws-gp-k8s-${ACCOUNT_ID} \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "terraform-state-dev-aws-gp-k8s-${ACCOUNT_ID}",
      "TargetPrefix": "logs/"
    }
  }'

aws s3api put-bucket-logging \
  --bucket terraform-state-staging-aws-gp-k8s-${ACCOUNT_ID} \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "terraform-state-staging-aws-gp-k8s-${ACCOUNT_ID}",
      "TargetPrefix": "logs/"
    }
  }'

aws s3api put-bucket-logging \
  --bucket terraform-state-prod-aws-gp-k8s-${ACCOUNT_ID} \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "terraform-state-prod-aws-gp-k8s-${ACCOUNT_ID}",
      "TargetPrefix": "logs/"
    }
  }'
```

## Backend Configuration

Each environment's `backend.tf` file should be configured as follows:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-{environment}-aws-gp-k8s-{account-id}"
    key            = "{environment}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    kms_key_id     = "alias/terraform-state-key"  # Optional: Use KMS for additional security
  }
}
```

## State Locking

Modern Terraform versions (1.5+) use S3's built-in locking mechanism, eliminating the need for DynamoDB tables. State locking is automatically handled by S3 with the following benefits:

- **Automatic Locking**: Prevents concurrent modifications to the same state
- **No Additional Infrastructure**: No need to manage DynamoDB tables
- **Cost Effective**: No additional AWS service costs
- **Simplified Setup**: Fewer resources to create and manage

### Lock Management

If you encounter a stuck lock, you can force unlock:

```bash
terraform force-unlock LOCK_ID
```

To find the lock ID, check the S3 bucket for lock files or use the AWS CLI:

```bash
aws s3 ls s3://terraform-state-{environment}-aws-gp-k8s-{account-id} --recursive | grep lock
```

## State Migration

If you need to migrate state from one backend to another:

```bash
# Initialize with new backend configuration
terraform init -reconfigure

# Or migrate state from local to remote
terraform init -migrate-state
```

## Security Best Practices

### 1. Bucket Policies

Create restrictive bucket policies to ensure only authorized access:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::terraform-state-*-aws-gp-k8s-*/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::terraform-state-*-aws-gp-k8s-*/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

### 2. IAM Permissions

Use least-privilege IAM policies for accessing state resources:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-state-{environment}-aws-gp-k8s-{account-id}",
        "arn:aws:s3:::terraform-state-{environment}-aws-gp-k8s-{account-id}/*"
      ]
    }
  ]
}
```

### 3. Encryption

- **Server-Side Encryption**: All state files are encrypted using AES256
- **KMS Encryption**: Optional KMS key for additional security
- **In-Transit Encryption**: HTTPS/TLS for all S3 communications

### 4. Access Logging

Enable access logging for audit purposes and security monitoring.

## State Management Best Practices

### 1. State Organization

- **Separate State Files**: Each environment has its own state file
- **Logical Separation**: Use different S3 buckets for different projects
- **Version Control**: Enable versioning for state recovery

### 2. State Security

- **Encryption**: Always encrypt state files at rest
- **Access Control**: Use IAM roles and policies for access control
- **Audit Logging**: Enable access logging for compliance

### 3. State Operations

- **Regular Backups**: Versioning provides automatic backups
- **State Inspection**: Use `terraform state` commands for inspection
- **State Import**: Import existing resources when needed

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure your AWS credentials have access to the S3 bucket
2. **Bucket Not Found**: Verify the bucket name and region
3. **Lock Timeout**: Check for stuck locks in S3
4. **Encryption Errors**: Ensure encryption is properly configured

### Useful Commands

```bash
# Check state list
terraform state list

# Show specific resource
terraform state show <resource>

# Remove resource from state
terraform state rm <resource>

# Import existing resource
terraform import <resource> <id>

# Check backend configuration
terraform init -backend-config=""

# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### Debugging State Issues

```bash
# Check S3 bucket contents
aws s3 ls s3://terraform-state-{environment}-aws-gp-k8s-{account-id} --recursive

# Check bucket policy
aws s3api get-bucket-policy --bucket terraform-state-{environment}-aws-gp-k8s-{account-id}

# Check encryption settings
aws s3api get-bucket-encryption --bucket terraform-state-{environment}-aws-gp-k8s-{account-id}

# Check public access settings
aws s3api get-public-access-block --bucket terraform-state-{environment}-aws-gp-k8s-{account-id}
```

## Cost Optimization

- **No DynamoDB Costs**: S3-only locking eliminates DynamoDB charges
- **Minimal Storage**: State files are typically small
- **Versioning Costs**: Minimal cost for versioning (only for changes)
- **Access Logging**: Optional but recommended for security

## Monitoring and Alerting

Consider setting up CloudWatch alarms for:

- **Bucket Access**: Monitor for unauthorized access attempts
- **Storage Usage**: Track state file growth
- **Error Rates**: Monitor for failed operations
- **Cost Monitoring**: Track S3 costs for state management 