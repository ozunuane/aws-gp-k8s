# Multi-Account AWS Infrastructure as Code with Terraform

[![Deploy Development](https://github.com/godspower/aws-gp-k8s/workflows/Deploy%20Development%20Environment/badge.svg)](https://github.com/godspower/aws-gp-k8s/actions)
[![Deploy Staging](https://github.com/godspower/aws-gp-k8s/workflows/Deploy%20Staging%20Environment/badge.svg)](https://github.com/godspower/aws-gp-k8s/actions)
[![Deploy Production](https://github.com/godspower/aws-gp-k8s/workflows/Deploy%20Production%20Environment/badge.svg)](https://github.com/godspower/aws-gp-k8s/actions)

A well-architected, production-grade Infrastructure as Code (IaC) repository using Terraform that provisions a multi-account AWS environment with reusable modules, IAM as code, and cost-optimized EKS clusters with Karpenter autoscaling.

## 🏗️ Architecture Overview

This repository implements a multi-account AWS architecture with the following components:

- **VPC**: Isolated networking with public/private subnets across multiple AZs, comprehensive VPC endpoints for secure AWS service access
- **EKS**: Managed Kubernetes clusters with optional Karpenter for autoscaling
- **IAM**: Comprehensive identity and access management as code
- **Middleware**: Optional managed services (Redis, Kafka, RabbitMQ, DocumentDB)
- **CI/CD**: GitHub Actions workflows with manual approvals for staging/production
- **DNS**: Route53 hosted zones with DNS resolver for internal/external domain resolution
- **SSL**: ACM certificates with automatic DNS validation

### 🔒 Security Features

- **VPC Endpoints**: All S3 traffic and AWS service communication routed through private endpoints
- **Private Subnets**: EKS nodes and applications run in private subnets
- **IAM as Code**: Least-privilege access with comprehensive policies
- **Encryption**: Data encrypted at rest and in transit
- **MFA Enforcement**: Required for staging and production environments

## 📁 Repository Structure

```
iac-terraform/
├── README.md                          # This file
├── modules/                           # Reusable Terraform modules
│   ├── vpc/                          # VPC with subnets, NAT, IGW
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/                          # EKS cluster with optional Karpenter
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── userdata.sh
│   ├── eks_karpenter/                # Dedicated Karpenter for cost optimization
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── userdata.sh
│   ├── middleware/                   # Managed services (Redis, Kafka, etc.)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                          # IAM users, groups, roles, policies
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ingress/                      # NGINX Ingress Controller
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── acm/                          # SSL Certificate Management
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── dns-resolver/                 # Route53 Resolver
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── policies/                         # External IAM policy JSON files
│   ├── ci_cd_pipeline.json          # CI/CD pipeline least-privilege policy
│   ├── eks_read_write.json          # EKS access for developers
│   └── read_only.json               # Read-only access for QA/readonly users
├── environments/                     # Environment-specific configurations
│   ├── dev/                         # Development environment
│   │   ├── main.tf                  # Module instantiation
│   │   ├── variables.tf             # Environment variables
│   │   ├── terraform.tfvars         # Variable values
│   │   ├── backend.tf               # S3 backend configuration
│   │   ├── provider.tf              # Provider configuration
│   │   ├── iam.tf                   # Environment-specific IAM
│   │   └── outputs.tf               # Environment outputs
│   ├── staging/                     # Staging environment
│   └── prod/                        # Production environment
├── globals/                          # Global variables and configuration
│   └── variables.tf                 # Shared variables across environments
├── shared/                          # Shared resources and documentation
│   └── state/
│       └── README.md                # State management documentation
├── docs/                            # Additional documentation
│   ├── vpc-endpoints.md             # VPC endpoints configuration guide
│   ├── deployment-guide.md          # Step-by-step deployment instructions
│   ├── DNS_RESOLVER.md              # DNS resolver configuration
│   ├── DOMAIN_CONFIGURATION.md      # Domain and SSL setup
│   ├── ROUTE53_SETUP.md             # Route53 configuration
│   ├── SSL_CERTIFICATE_SETUP.md     # SSL certificate management
│   ├── SUMMARY.md                   # Infrastructure overview
│   └── troubleshooting.md           # Common issues and solutions
└── .github/                         # GitHub Actions workflows
    └── workflows/
        ├── deploy-dev.yml           # Development deployment
        ├── deploy-staging.yml       # Staging deployment (with approval)
        └── deploy-prod.yml          # Production deployment (with approval)
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.5.0 installed
3. **kubectl** for Kubernetes management
4. **Helm** for package management (optional)

### ⚠️ **CRITICAL: Before Deployment**

**You MUST update the following placeholder values before deploying:**

1. **AWS Account IDs** in backend configuration:
   ```bash
   # Update these files with your actual AWS account IDs
   environments/dev/backend.tf
   environments/staging/backend.tf
   environments/prod/backend.tf
   ```

2. **Domain Names** in terraform.tfvars:
   ```bash
   # Replace "example.com" with your actual domains
   environments/dev/terraform.tfvars
   environments/staging/terraform.tfvars
   environments/prod/terraform.tfvars
   ```

3. **GitHub Organization** references:
   ```bash
   # Replace "godspower" with your actual GitHub organization
   # Update in all terraform.tfvars files and README.md
   ```

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/godspower/aws-gp-k8s.git
   cd aws-gp-k8s/iac-terraform
   ```

2. **Update placeholder values** (see critical section above)

3. **Create S3 buckets for state management**
   
   Replace `{account-id}` with your actual AWS account ID:
   
   ```bash
   # Create S3 buckets
   aws s3 mb s3://terraform-state-dev-aws-gp-k8s-{account-id}
   aws s3 mb s3://terraform-state-staging-aws-gp-k8s-{account-id}
   aws s3 mb s3://terraform-state-prod-aws-gp-k8s-{account-id}
   
   # Enable versioning
   aws s3api put-bucket-versioning --bucket terraform-state-dev-aws-gp-k8s-{account-id} --versioning-configuration Status=Enabled
   aws s3api put-bucket-versioning --bucket terraform-state-staging-aws-gp-k8s-{account-id} --versioning-configuration Status=Enabled
   aws s3api put-bucket-versioning --bucket terraform-state-prod-aws-gp-k8s-{account-id} --versioning-configuration Status=Enabled
   
   # Enable encryption
   aws s3api put-bucket-encryption --bucket terraform-state-dev-aws-gp-k8s-{account-id} --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
   aws s3api put-bucket-encryption --bucket terraform-state-staging-aws-gp-k8s-{account-id} --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
   aws s3api put-bucket-encryption --bucket terraform-state-prod-aws-gp-k8s-{account-id} --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
   
   # Enable public access blocking
   aws s3api put-public-access-block --bucket terraform-state-dev-aws-gp-k8s-{account-id} --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
   aws s3api put-public-access-block --bucket terraform-state-staging-aws-gp-k8s-{account-id} --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
   aws s3api put-public-access-block --bucket terraform-state-prod-aws-gp-k8s-{account-id} --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
   ```

4. **Update backend configuration**
   
   Update the `backend.tf` files in each environment directory with your actual account ID.

5. **Configure GitHub Actions**
   
   Set up GitHub Environments and secrets as described in the deployment guide.

### Deploying an Environment

#### Development Environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

#### Staging Environment

```bash
cd environments/staging
terraform init
terraform plan
terraform apply
```

#### Production Environment

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

## 🔧 Module Usage

### VPC Module

Creates a VPC with public and private subnets across multiple availability zones, including comprehensive VPC endpoints for secure AWS service access.

**Key Features:**
- **S3 Gateway Endpoint**: Routes ALL S3 traffic through VPC endpoint (no internet access required)
- **Interface Endpoints**: Private communication with EC2, ECR, EKS, CloudWatch, Secrets Manager, and SSM
- **Security Groups**: Restricted access to VPC endpoints
- **Route Table Integration**: Automatic routing configuration

```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  environment             = "dev"
  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway     = true
  enable_vpc_endpoints   = true
  
  # Granular control over VPC endpoints
  vpc_endpoints_config = {
    s3             = true   # Always enabled for S3 access
    ec2            = true   # For EKS and node management
    ecr_api        = true   # For container registry API
    ecr_dkr        = true   # For Docker registry operations
    eks            = true   # For EKS API
    logs           = true   # For CloudWatch logs
    secretsmanager = true   # For secret management
    ssm            = true   # For Systems Manager
    ssm_messages   = true   # For SSM messaging
    ec2_messages   = true   # For EC2 messaging
  }
  
  tags = {
    Environment = "dev"
    Project     = "aws-gp-k8s"
  }
}
```

**📖 For detailed VPC endpoints configuration, see [VPC Endpoints Documentation](docs/vpc-endpoints.md)**

### EKS Module

Creates an EKS cluster with managed node groups and optional Karpenter.

```hcl
module "eks" {
  source = "../../modules/eks"
  
  environment                = "dev"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  kubernetes_version        = "1.28"
  node_group_instance_types = ["t3.medium"]
  enable_karpenter         = false
  
  tags = {
    Environment = "dev"
    Project     = "aws-gp-k8s"
  }
}
```

### EKS Karpenter Module

Creates a dedicated Karpenter installation for cost-optimized mixed on-demand and spot instances.

```hcl
module "eks_karpenter" {
  source = "../../modules/eks_karpenter"
  
  environment              = "dev"
  cluster_name            = module.eks.cluster_name
  cluster_arn             = module.eks.cluster_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
  
  tags = {
    Environment = "dev"
    Project     = "aws-gp-k8s"
  }
}
```

### ACM Module

Manages SSL certificates with automatic DNS validation and Route53 integration.

```hcl
module "acm" {
  source = "../../modules/acm"
  
  environment = "dev"
  
  domains = {
    public = {
      domain_name = "example.com"
      subdomains = ["www", "api", "app"]
      wildcard_subdomains = ["api", "app"]
      hosted_zone_type = "public"
      load_balancer_type = "external"
    }
    private = {
      domain_name = "internal.example.com"
      hosted_zone_type = "private"
      vpc_id = module.vpc.vpc_id
      load_balancer_type = "internal"
    }
  }
  
  load_balancer_dns_name = module.ingress.external_load_balancer_hostname
  load_balancer_zone_id  = module.ingress.external_load_balancer_zone_id
  
  tags = {
    Environment = "dev"
    Project     = "aws-gp-k8s"
  }
}
```

### DNS Resolver Module

Configures Route53 Resolver for internal and external DNS resolution.

```hcl
module "dns_resolver" {
  source = "../../modules/dns-resolver"
  
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = module.vpc.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnet_ids
  
  enable_outbound_resolver = true
  enable_inbound_resolver  = true
  
  resolver_rules = {
    "corporate-dns" = {
      domain_name = "corporate.example.com"
      name        = "corporate-dns-forward"
      target_ips  = ["8.8.8.8", "8.8.4.4"]
    }
  }
  
  tags = {
    Environment = "dev"
    Project     = "aws-gp-k8s"
  }
}
```

## 🎯 Karpenter Workload Scheduling

### Critical Workloads (On-Demand)

For critical workloads that require high availability, use the `critical` workload type:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
spec:
  template:
    spec:
      nodeSelector:
        workload-type: critical
      tolerations:
        - key: workload-type
          operator: Equal
          value: critical
          effect: NoSchedule
      containers:
        - name: app
          image: nginx
```

### Non-Critical Workloads (Spot + On-Demand)

For cost-optimized workloads that can tolerate interruptions:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: non-critical-app
spec:
  template:
    spec:
      nodeSelector:
        workload-type: non-critical
      tolerations:
        - key: workload-type
          operator: Equal
          value: non-critical
          effect: NoSchedule
      containers:
        - name: app
          image: nginx
```

## 👥 IAM Management

### User Groups

The repository creates four user groups:

- **devops**: Full administrative access
- **developers**: PowerUser access with EKS permissions and S3 bucket management (dev environment only)
- **qa**: Read-only access to QA resources
- **readonly**: Read-only access across all resources

### Adding Users

Update the `terraform.tfvars` file in each environment:

```hcl
devops_users = {
  "devops1" = {
    name = "john.doe"
  }
  "devops2" = {
    name = "jane.smith"
  }
}

developer_users = {
  "dev1" = {
    name = "alice.johnson"
  }
  "dev2" = {
    name = "bob.wilson"
  }
}
```

### Access Key Configuration

**Development Environment:**
- `create_access_keys = true` - Creates access keys for programmatic S3 access
- Developers get both EKS and S3 permissions with access keys

**Staging/Production Environments:**
- `create_access_keys = false` - No access keys for security
- Use IAM roles and temporary credentials instead

### Retrieving Access Keys

After deployment, retrieve access keys for developers:

```bash
# Get access keys for a specific user
terraform output developer_access_keys

# Or get all access keys
terraform output -json | jq '.developer_access_keys.value'
```

**Example Output:**
```json
{
  "dev1": {
    "access_key_id": "AKIA...",
    "secret_access_key": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  },
  "dev2": {
    "access_key_id": "AKIA...",
    "secret_access_key": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  }
}
```

**⚠️ Security Note:** Access keys are sensitive and should be shared securely with developers.

### Custom Policies

IAM policies are stored as JSON files in the `policies/` directory:

- `ci_cd_pipeline.json`: Full administrative access for CI/CD operations (required for Terraform deployments)
- `ci_cd_pipeline_granular.json`: Granular least-privilege policy (backup for restrictive environments)
- `eks_read_write.json`: EKS access for developers
- `developer_s3_access.json`: S3 bucket creation and management access for developers (dev environment only)
- `read_only.json`: Read-only access for QA and readonly users

## 🔄 CI/CD Workflows

### GitHub Actions Setup

1. **Create GitHub Environments**
   
   Go to your repository settings and create environments:
   - `staging` (with required reviewers)
   - `production` (with required reviewers)

2. **Configure Secrets**
   
   Add the following secrets to your repository:
   - `AWS_ROLE_ARN_DEV`: IAM role ARN for development
   - `AWS_ROLE_ARN_STAGING`: IAM role ARN for staging
   - `AWS_ROLE_ARN_PROD`: IAM role ARN for production

3. **Branch Protection**
   
   Set up branch protection rules:
   - `main`: Require pull request reviews, require status checks
   - `staging`: Require pull request reviews
   - `dev`: Basic protection

### Workflow Triggers

- **Development**: Triggered on push to `dev` branch
- **Staging**: Triggered on push to `staging` branch (requires manual approval)
- **Production**: Triggered on push to `main` branch (requires manual approval)

### Deployment Process

1. **Development**: Automatic deployment on push to `dev`
2. **Staging**: Plan runs automatically, apply requires manual approval
3. **Production**: Plan runs automatically, apply requires manual approval and creates a release

## 🛠️ Customization

### Adding New Modules

1. Create a new directory under `modules/`
2. Add `main.tf`, `variables.tf`, and `outputs.tf`
3. Update environment configurations to use the new module

### Environment-Specific Configuration

Each environment can have different configurations:

- **Development**: Minimal resources, relaxed security
- **Staging**: Production-like setup with cost optimization
- **Production**: Full HA setup with enhanced security

### Multi-Cloud Support

The repository is designed to be extensible for multi-cloud deployments:

1. Add new provider configurations
2. Create cloud-specific modules
3. Update environment configurations

## 📊 Cost Optimization

### Karpenter Configuration

- **Critical workloads**: On-demand instances for reliability
- **Non-critical workloads**: Spot instances with on-demand fallback
- **Automatic scaling**: Based on workload demands

### Environment-Specific Optimizations

- **Development**: Single AZ, smaller instances, no NAT Gateway
- **Staging**: Multi-AZ, spot instances where possible
- **Production**: Full HA with cost-optimized autoscaling

## 🔍 Monitoring and Troubleshooting

### Terraform State

- State files are stored in S3 with versioning enabled
- S3 provides built-in state locking (no DynamoDB required)
- Each environment has isolated state
- State files are encrypted at rest

### Common Issues

1. **State Lock**: Use `terraform force-unlock LOCK_ID`
2. **Provider Issues**: Check AWS credentials and permissions
3. **Module Errors**: Verify module source paths and versions
4. **VPC Endpoint Issues**: Check security groups and route table associations

### Useful Commands

```bash
# Check state
terraform state list

# Show specific resource
terraform state show module.vpc.aws_vpc.main

# Import existing resource
terraform import module.vpc.aws_vpc.main vpc-12345678

# Refresh state
terraform refresh

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Check VPC endpoints
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Verify S3 routing through VPC endpoint
aws s3 ls --endpoint-url https://s3.us-west-2.amazonaws.com
```

## 🔒 Security Considerations

### IAM Best Practices

- Least-privilege access policies
- MFA enforcement for production
- Regular access reviews
- Separate roles for different environments

### Network Security

- Private subnets for workloads
- Security groups with minimal required access
- VPC endpoints for AWS services
- Network ACLs for additional security

## 🛡️ VPC Endpoints Security

### Overview

This infrastructure implements comprehensive VPC endpoints to ensure secure, private communication with AWS services without requiring internet access.

### Key Security Features

#### **S3 Gateway Endpoint**
- **Universal Routing**: ALL S3 traffic routed through VPC endpoint
- **No Internet Access**: Traffic never leaves AWS network
- **Cost Optimization**: No data transfer charges
- **Comprehensive Policy**: Allows all S3 operations with proper security

#### **Interface Endpoints**
- **EC2**: Private EKS cluster management and node provisioning
- **ECR API & DKR**: Secure container registry operations
- **EKS**: Private EKS API communication
- **CloudWatch Logs**: Private application logging
- **Secrets Manager**: Secure secret management
- **SSM & SSM Messages**: Private Systems Manager operations
- **EC2 Messages**: Private EC2 messaging services

### Security Benefits

1. **Network Isolation**: All AWS service traffic stays within AWS network
2. **Reduced Attack Surface**: No internet exposure for AWS service access
3. **Compliance**: Helps meet security requirements for private networks
4. **Data Protection**: Sensitive data never traverses the public internet

### Configuration Examples

#### **Development Environment**
```hcl
enable_vpc_endpoints = true
vpc_endpoints_config = {
  s3             = true   # Always enabled
  ec2            = true   # EKS management
  ecr_api        = true   # Container registry
  ecr_dkr        = true   # Docker operations
  eks            = true   # EKS API
  logs           = false  # Optional for dev
  secretsmanager = false  # Optional for dev
  ssm            = false  # Optional for dev
  ssm_messages   = false  # Optional for dev
  ec2_messages   = false  # Optional for dev
}
```

#### **Production Environment**
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

### Monitoring and Verification

#### **Check VPC Endpoint Status**
```bash
# List all VPC endpoints
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Verify S3 routing
aws s3 ls --endpoint-url https://s3.us-west-2.amazonaws.com
```

#### **Security Group Verification**
```bash
# Check VPC endpoint security groups
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx
```

**📖 For detailed VPC endpoints configuration and troubleshooting, see [VPC Endpoints Documentation](docs/vpc-endpoints.md)**

### Secrets Management

- Use AWS Secrets Manager for sensitive data
- Encrypt all data at rest and in transit
- Regular rotation of credentials
- No hardcoded secrets in code

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Karpenter Documentation](https://karpenter.sh/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For questions or issues:

1. Check the troubleshooting section
2. Review GitHub Issues
3. Contact the DevOps team
4. Create a new issue with detailed information

---

**Note**: Remember to update the repository URL, organization name, and other specific details before using this repository in production. 