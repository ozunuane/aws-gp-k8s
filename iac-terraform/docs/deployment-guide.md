# Deployment Guide

This guide provides step-by-step instructions for deploying the AWS GP K8s infrastructure across all environments.

## 📋 Prerequisites

### Required Tools
- **AWS CLI** (v2.x or later)
- **Terraform** (>= 1.5.0)
- **kubectl** (for Kubernetes management)
- **Helm** (optional, for package management)

### AWS Account Setup
- AWS account with appropriate permissions
- IAM user or role with administrative access
- AWS region configured (default: us-west-2)

### GitHub Setup
- GitHub repository with GitHub Actions enabled
- GitHub Environments configured (staging, production)
- Repository secrets configured

## 🚀 Initial Setup

### 1. Repository Setup

```bash
# Clone the repository
git clone https://github.com/your-org/aws-gp-k8s.git
cd aws-gp-k8s/iac-terraform

# Verify the structure
ls -la
```

### 2. AWS Credentials Configuration

```bash
# Configure AWS CLI
aws configure

# Or use AWS SSO
aws configure sso
```

### 3. State Management Setup

#### Create S3 Buckets for Terraform State

Replace `{account-id}` with your actual AWS account ID:

```bash
# Create S3 buckets
aws s3 mb s3://terraform-state-dev-aws-gp-k8s-{account-id}
aws s3 mb s3://terraform-state-staging-aws-gp-k8s-{account-id}
aws s3 mb s3://terraform-state-prod-aws-gp-k8s-{account-id}

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-dev-aws-gp-k8s-{account-id} \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-versioning \
  --bucket terraform-state-staging-aws-gp-k8s-{account-id} \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-versioning \
  --bucket terraform-state-prod-aws-gp-k8s-{account-id} \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-dev-aws-gp-k8s-{account-id} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

aws s3api put-bucket-encryption \
  --bucket terraform-state-staging-aws-gp-k8s-{account-id} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

aws s3api put-bucket-encryption \
  --bucket terraform-state-prod-aws-gp-k8s-{account-id} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Enable public access blocking
aws s3api put-public-access-block \
  --bucket terraform-state-dev-aws-gp-k8s-{account-id} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-public-access-block \
  --bucket terraform-state-staging-aws-gp-k8s-{account-id} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-public-access-block \
  --bucket terraform-state-prod-aws-gp-k8s-{account-id} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

### 4. Configuration Updates

#### Update Backend Configuration

Update the `backend.tf` files in each environment directory:

```bash
# Development
sed -i 's/REPLACE-WITH-ACCOUNT-ID/{your-actual-account-id}/g' environments/dev/backend.tf

# Staging
sed -i 's/REPLACE-WITH-ACCOUNT-ID/{your-actual-account-id}/g' environments/staging/backend.tf

# Production
sed -i 's/REPLACE-WITH-ACCOUNT-ID/{your-actual-account-id}/g' environments/prod/backend.tf
```

#### Update GitHub Repository References

Update GitHub repository references in `terraform.tfvars` files:

```bash
# Replace with your actual GitHub organization and repository
sed -i 's/your-org/{your-github-org}/g' environments/*/terraform.tfvars
sed -i 's/aws-gp-k8s/{your-repo-name}/g' environments/*/terraform.tfvars
```

## 🏗️ Environment Deployment

### Development Environment

```bash
cd environments/dev

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Verify the deployment
terraform output
```

### Staging Environment

```bash
cd environments/staging

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration (requires manual approval in CI/CD)
terraform apply

# Verify the deployment
terraform output
```

### Production Environment

```bash
cd environments/prod

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration (requires manual approval in CI/CD)
terraform apply

# Verify the deployment
terraform output
```

## 🔒 VPC Endpoints Verification

### Verify S3 Gateway Endpoint

```bash
# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*-vpc" --query 'Vpcs[0].VpcId' --output text)

# Check S3 endpoint
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=service-name,Values=*.s3" \
  --query 'VpcEndpoints[0]'

# Test S3 access through VPC endpoint
aws s3 ls --endpoint-url https://s3.us-west-2.amazonaws.com
```

### Verify Interface Endpoints

```bash
# List all VPC endpoints
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'VpcEndpoints[].{ServiceName:ServiceName,State:State,VpcEndpointType:VpcEndpointType}'
```

### Verify Route Table Associations

```bash
# Get route table IDs
ROUTE_TABLES=$(aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'RouteTables[].RouteTableId' \
  --output text)

# Check S3 endpoint associations
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=service-name,Values=*.s3" \
  --query 'VpcEndpoints[0].RouteTableIds'
```

## 🚀 EKS Cluster Setup

### Configure kubectl

```bash
# Get cluster name
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name $CLUSTER_NAME

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Deploy Karpenter (if enabled)

```bash
# Check if Karpenter is enabled
if terraform output -raw karpenter_controller_role_arn 2>/dev/null; then
  echo "Karpenter is enabled, deploying..."
  
  # Deploy Karpenter
  kubectl apply -f https://raw.githubusercontent.com/aws/karpenter/main/pkg/apis/crds/karpenter.sh_provisioners.yaml
  kubectl apply -f https://raw.githubusercontent.com/aws/karpenter/main/pkg/apis/crds/karpenter.sh_machines.yaml
  
  # Apply Karpenter configuration
  kubectl apply -f karpenter-config.yaml
else
  echo "Karpenter is not enabled for this environment"
fi
```

## 🔧 Post-Deployment Configuration

### IAM User Setup

1. **Create IAM Users**
   - Users are created automatically based on `terraform.tfvars`
   - Access keys are generated for development environment only

2. **Configure AWS CLI for Users**
   ```bash
   # For each user, configure AWS CLI
   aws configure
   # Enter the access key and secret key
   ```

3. **Test User Permissions**
   ```bash
   # Test S3 access
   aws s3 ls
   
   # Test EKS access
   aws eks list-clusters
   ```

### GitHub Actions Setup

1. **Create GitHub Environments**
   - Go to repository Settings > Environments
   - Create `staging` and `production` environments
   - Add required reviewers

2. **Configure Repository Secrets**
   ```
   AWS_ROLE_ARN_DEV: arn:aws:iam::ACCOUNT:role/github-actions-dev
   AWS_ROLE_ARN_STAGING: arn:aws:iam::ACCOUNT:role/github-actions-staging
   AWS_ROLE_ARN_PROD: arn:aws:iam::ACCOUNT:role/github-actions-prod
   ```

3. **Set Up Branch Protection**
   - `main`: Require pull request reviews, require status checks
   - `staging`: Require pull request reviews
   - `dev`: Basic protection

## 🧪 Testing and Validation

### Network Connectivity Tests

```bash
# Test VPC endpoint connectivity
kubectl run test-pod --image=amazon/aws-cli --rm -it --restart=Never -- \
  aws s3 ls

# Test ECR access
kubectl run test-pod --image=amazon/aws-cli --rm -it --restart=Never -- \
  aws ecr describe-repositories

# Test CloudWatch logs
kubectl run test-pod --image=amazon/aws-cli --rm -it --restart=Never -- \
  aws logs describe-log-groups
```

### Application Deployment Test

```bash
# Deploy a test application
kubectl create deployment nginx --image=nginx

# Check if it's running
kubectl get pods

# Test service connectivity
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

## 🔍 Monitoring and Troubleshooting

### Common Issues and Solutions

#### Issue: VPC Endpoint Not Responding
```bash
# Check security group rules
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw vpc_endpoints_security_group_id)

# Verify route table associations
aws ec2 describe-route-tables \
  --route-table-ids $(terraform output -raw public_route_table_id)
```

#### Issue: EKS Cluster Not Accessible
```bash
# Check cluster status
aws eks describe-cluster --name $(terraform output -raw eks_cluster_name)

# Verify security groups
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw eks_cluster_security_group_id)
```

#### Issue: S3 Access Failing
```bash
# Test S3 endpoint directly
aws s3 ls --endpoint-url https://s3.us-west-2.amazonaws.com

# Check VPC endpoint policy
aws ec2 describe-vpc-endpoints \
  --vpc-endpoint-ids $(terraform output -raw s3_endpoint_id) \
  --query 'VpcEndpoints[0].PolicyDocument'
```

### Useful Commands

```bash
# Check all resources
terraform state list

# Show specific resource
terraform state show module.vpc.aws_vpc.main

# Refresh state
terraform refresh

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Check VPC endpoints
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

## 📊 Cost Optimization

### Monitor Costs

```bash
# Check current costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# Monitor VPC endpoint costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon VPC"]}}'
```

### Optimization Tips

1. **Use Spot Instances**: Configure Karpenter to use spot instances for non-critical workloads
2. **Right-size Resources**: Monitor resource usage and adjust instance types
3. **Clean Up Unused Resources**: Regularly review and remove unused resources
4. **Use Reserved Instances**: For predictable workloads in production

## 🔄 Maintenance and Updates

### Regular Maintenance Tasks

1. **Update Terraform and Providers**
   ```bash
   terraform init -upgrade
   ```

2. **Review Security Groups**
   ```bash
   aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
   ```

3. **Check VPC Endpoint Health**
   ```bash
   aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
   ```

4. **Update Kubernetes Version**
   - Plan and apply EKS cluster updates
   - Test in development first

### Backup and Recovery

1. **Terraform State Backup**
   - State is automatically backed up in S3
   - Versioning is enabled for rollback capability

2. **EKS Cluster Backup**
   - Use Velero for application backups
   - Regular EBS snapshot backups for persistent volumes

## 📚 Additional Resources

- [VPC Endpoints Documentation](vpc-endpoints.md)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Karpenter Documentation](https://karpenter.sh/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Note**: Always test changes in development environment first before applying to staging or production. 