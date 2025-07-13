# Gradual Deployment Guide

This guide explains different strategies for deploying Terraform resources gradually, allowing you to manage deployments step-by-step and troubleshoot issues more effectively.

## 🎯 **Why Gradual Deployment?**

- **Risk Mitigation**: Deploy resources in small batches to minimize impact
- **Troubleshooting**: Easier to identify and fix issues when deploying incrementally
- **Testing**: Validate each component before moving to the next
- **Rollback**: Quick rollback of specific components if needed
- **Cost Control**: Deploy expensive resources only when needed

## 🚀 **Strategy 1: Feature Flags with Count (Recommended)**

This is the **cleanest and most maintainable** approach using boolean variables to control entire modules.

### **Implementation**

```hcl
# variables.tf
variable "enable_vpc" {
  description = "Enable VPC module deployment"
  type        = bool
  default     = true
}

variable "enable_eks" {
  description = "Enable EKS module deployment"
  type        = bool
  default     = true
}

variable "enable_postgres" {
  description = "Enable PostgreSQL RDS deployment"
  type        = bool
  default     = true
}

# main.tf
module "vpc" {
  source = "../../modules/vpc"
  count  = var.enable_vpc ? 1 : 0
  
  # ... configuration
}

module "eks" {
  source = "../../modules/eks"
  count  = var.enable_eks ? 1 : 0
  
  vpc_id = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  # ... configuration
}

module "postgres" {
  source = "../../modules/rds-postgres"
  count  = var.enable_postgres ? 1 : 0
  
  vpc_id = var.enable_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  # ... configuration
}
```

### **Usage Examples**

#### **Phase 1: Deploy VPC Only**
```hcl
# terraform.tfvars
enable_vpc = true
enable_eks = false
enable_postgres = false
```

#### **Phase 2: Add EKS**
```hcl
# terraform.tfvars
enable_vpc = true
enable_eks = true
enable_postgres = false
```

#### **Phase 3: Add Databases**
```hcl
# terraform.tfvars
enable_vpc = true
enable_eks = true
enable_postgres = true
enable_mysql = true
```

### **Pros**
- ✅ Clean and readable
- ✅ Easy to understand and maintain
- ✅ Supports existing resource references
- ✅ No complex conditional logic
- ✅ Works well with Terraform's dependency management

### **Cons**
- ❌ Requires handling existing resources when modules are disabled
- ❌ Need to manage conditional outputs

---

## 🔧 **Strategy 2: Terraform Workspaces**

Use separate Terraform workspaces for different deployment phases.

### **Implementation**

```bash
# Create workspaces
terraform workspace new vpc-only
terraform workspace new vpc-eks
terraform workspace new vpc-eks-databases
terraform workspace new full-deployment

# Switch to workspace
terraform workspace select vpc-only
```

### **Usage**

```hcl
# main.tf - Use workspace-specific configurations
locals {
  workspace = terraform.workspace
  
  # Define what to deploy based on workspace
  deploy_vpc = contains(["vpc-only", "vpc-eks", "vpc-eks-databases", "full-deployment"], local.workspace)
  deploy_eks = contains(["vpc-eks", "vpc-eks-databases", "full-deployment"], local.workspace)
  deploy_postgres = contains(["vpc-eks-databases", "full-deployment"], local.workspace)
}

module "vpc" {
  source = "../../modules/vpc"
  count  = local.deploy_vpc ? 1 : 0
  # ... configuration
}
```

### **Pros**
- ✅ Complete isolation between phases
- ✅ Easy rollback by switching workspaces
- ✅ No need for existing resource variables
- ✅ Clean state management

### **Cons**
- ❌ More complex state management
- ❌ Need to handle workspace switching carefully
- ❌ Can be confusing for team members

---

## 📁 **Strategy 3: Separate Configuration Files**

Create separate Terraform configurations for different deployment phases.

### **Implementation**

```
environments/dev/
├── phase1-vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── phase2-eks/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── phase3-databases/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── full-deployment/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

### **Usage**

```bash
# Deploy phase by phase
cd phase1-vpc
terraform init
terraform apply

cd ../phase2-eks
terraform init
terraform apply

cd ../phase3-databases
terraform init
terraform apply
```

### **Pros**
- ✅ Complete separation of concerns
- ✅ Very clear what each phase deploys
- ✅ Easy to understand and maintain
- ✅ No conditional logic needed

### **Cons**
- ❌ Code duplication
- ❌ More complex to manage
- ❌ Need to handle data sources between phases
- ❌ More files to maintain

---

## 🎛️ **Strategy 4: Terraform Modules with Conditional Resources**

Use conditional logic within modules to control individual resources.

### **Implementation**

```hcl
# modules/infrastructure/main.tf
module "vpc" {
  source = "../vpc"
  count  = var.deploy_vpc ? 1 : 0
  # ... configuration
}

module "eks" {
  source = "../eks"
  count  = var.deploy_eks ? 1 : 0
  
  vpc_id = var.deploy_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  # ... configuration
}

# Use data sources for existing resources
data "aws_vpc" "existing" {
  count = var.deploy_vpc ? 0 : 1
  id    = var.existing_vpc_id
}
```

### **Pros**
- ✅ Granular control over resources
- ✅ Can mix new and existing resources
- ✅ Flexible deployment options

### **Cons**
- ❌ Complex conditional logic
- ❌ Harder to maintain
- ❌ More prone to errors

---

## 🏆 **Recommended Approach: Feature Flags with Count**

For most use cases, we recommend **Strategy 1: Feature Flags with Count** because it provides:

1. **Simplicity**: Easy to understand and implement
2. **Maintainability**: Clean code structure
3. **Flexibility**: Can handle both new and existing resources
4. **Team-Friendly**: Clear for all team members
5. **Terraform-Native**: Uses Terraform's built-in features

## 📋 **Deployment Checklist**

### **Phase 1: Foundation**
- [ ] VPC and Networking
- [ ] Security Groups
- [ ] IAM Roles and Policies

### **Phase 2: Compute**
- [ ] EKS Cluster
- [ ] Node Groups
- [ ] Karpenter (if using)

### **Phase 3: Networking Services**
- [ ] Load Balancers
- [ ] Ingress Controllers
- [ ] DNS Configuration

### **Phase 4: Data Layer**
- [ ] RDS Databases
- [ ] Middleware Services
- [ ] Backup Configuration

### **Phase 5: Monitoring & Security**
- [ ] CloudWatch Logging
- [ ] Performance Insights
- [ ] Security Hardening

## 🔄 **Rollback Strategy**

### **Quick Rollback**
```bash
# Disable specific modules
terraform apply -var="enable_postgres=false" -var="enable_mysql=false"
```

### **Full Rollback**
```bash
# Destroy specific resources
terraform destroy -target=module.postgres -target=module.mysql
```

### **State Rollback**
```bash
# Rollback to previous state
terraform plan -refresh=false
terraform apply -refresh=false
```

## 🛠️ **Best Practices**

1. **Start Small**: Begin with essential infrastructure (VPC, IAM)
2. **Test Each Phase**: Validate each phase before moving to the next
3. **Document Dependencies**: Clearly document resource dependencies
4. **Use Consistent Naming**: Maintain consistent naming conventions
5. **Monitor Costs**: Track costs at each phase
6. **Backup State**: Regularly backup Terraform state
7. **Team Communication**: Keep team informed of deployment phases

## 📊 **Example Deployment Timeline**

| Phase | Duration | Resources | Risk Level |
|-------|----------|-----------|------------|
| 1 - VPC | 30 min | VPC, Subnets, Security Groups | Low |
| 2 - EKS | 45 min | EKS Cluster, Node Groups | Medium |
| 3 - Ingress | 30 min | Load Balancers, Ingress Controllers | Medium |
| 4 - Databases | 60 min | RDS Instances, Read Replicas | High |
| 5 - Monitoring | 30 min | CloudWatch, Performance Insights | Low |

## 🚨 **Troubleshooting Tips**

1. **Check Dependencies**: Ensure all required resources are deployed
2. **Validate Variables**: Verify all required variables are set
3. **Review Logs**: Check CloudWatch logs for application issues
4. **Test Connectivity**: Verify network connectivity between components
5. **Monitor Resources**: Use AWS Console to verify resource creation

This approach ensures a smooth, controlled deployment process while maintaining the ability to troubleshoot and rollback as needed. 