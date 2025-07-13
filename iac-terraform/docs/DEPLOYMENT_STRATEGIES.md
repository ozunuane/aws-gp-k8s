# Terraform Deployment Strategies Comparison

This document compares different approaches for managing gradual deployments in Terraform infrastructure.

## 🎯 **The Problem**

When deploying complex infrastructure with many interdependent resources, you want to:
- Deploy resources in phases to minimize risk
- Troubleshoot issues more effectively
- Rollback specific components if needed
- Control costs by deploying expensive resources only when needed

## 🚀 **Strategy 1: Feature Flags with Count (IMPLEMENTED)**

**Status**: ✅ **Implemented and Recommended**

### **How It Works**
- Use boolean variables to control entire modules
- Modules use `count = var.enable_module ? 1 : 0`
- Conditional logic handles dependencies between enabled/disabled modules
- Support for existing resources when modules are disabled

### **Implementation**
```hcl
# variables.tf
variable "enable_vpc" {
  description = "Enable VPC module deployment"
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
```

### **Usage Examples**

#### **Phase 1: VPC Only**
```hcl
enable_vpc = true
enable_eks = false
enable_postgres = false
```

#### **Phase 2: Add EKS**
```hcl
enable_vpc = true
enable_eks = true
enable_postgres = false
```

#### **Phase 3: Add Databases**
```hcl
enable_vpc = true
enable_eks = true
enable_postgres = true
enable_mysql = true
```

### **Pros**
- ✅ Clean and readable code
- ✅ Easy to understand and maintain
- ✅ Supports existing resource references
- ✅ No complex conditional logic
- ✅ Works well with Terraform's dependency management
- ✅ Automated deployment script available
- ✅ Comprehensive documentation

### **Cons**
- ❌ Requires handling existing resources when modules are disabled
- ❌ Need to manage conditional outputs

### **Files Modified**
- `environments/dev/variables.tf` - Added feature flag variables
- `environments/dev/main.tf` - Updated with count and conditional logic
- `environments/dev/outputs.tf` - Updated to handle conditional modules
- `environments/dev/terraform.tfvars.example` - Added feature flag examples
- `scripts/deploy-phases.sh` - Automated deployment script
- `docs/GRADUAL_DEPLOYMENT_GUIDE.md` - Comprehensive guide

---

## 🔧 **Strategy 2: Terraform Workspaces**

**Status**: ❌ **Not Implemented** (Alternative approach)

### **How It Works**
- Use separate Terraform workspaces for different deployment phases
- Each workspace has its own state and configuration
- Switch between workspaces to manage different phases

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
- ❌ Requires additional setup and documentation

---

## 📁 **Strategy 3: Separate Configuration Files**

**Status**: ❌ **Not Implemented** (Alternative approach)

### **How It Works**
- Create separate Terraform configurations for different deployment phases
- Each phase has its own directory with complete configuration
- Deploy phases sequentially

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

**Status**: ❌ **Not Implemented** (Alternative approach)

### **How It Works**
- Use conditional logic within modules to control individual resources
- Mix new and existing resources in the same configuration
- Use data sources for existing resources

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

## 🏆 **Recommendation: Feature Flags with Count**

We have implemented **Strategy 1: Feature Flags with Count** because it provides the best balance of:

1. **Simplicity**: Easy to understand and implement
2. **Maintainability**: Clean code structure
3. **Flexibility**: Can handle both new and existing resources
4. **Team-Friendly**: Clear for all team members
5. **Terraform-Native**: Uses Terraform's built-in features
6. **Automation**: Includes deployment scripts and documentation

## 📊 **Comparison Matrix**

| Strategy | Complexity | Maintainability | Flexibility | Team-Friendly | Automation |
|----------|------------|-----------------|-------------|---------------|------------|
| Feature Flags | Low | High | High | High | ✅ |
| Workspaces | Medium | Medium | Medium | Medium | ❌ |
| Separate Files | Low | Medium | Low | High | ❌ |
| Conditional Resources | High | Low | High | Low | ❌ |

## 🚀 **Getting Started**

### **Quick Start**
```bash
# Deploy VPC only
./scripts/deploy-phases.sh dev phase1

# Add EKS cluster
./scripts/deploy-phases.sh dev phase2

# Add ingress and load balancers
./scripts/deploy-phases.sh dev phase3

# Add databases
./scripts/deploy-phases.sh dev phase4

# Deploy everything at once
./scripts/deploy-phases.sh dev all
```

### **Manual Deployment**
```bash
cd environments/dev

# Phase 1: VPC only
echo 'enable_vpc = true' > terraform.tfvars
echo 'enable_eks = false' >> terraform.tfvars
echo 'enable_postgres = false' >> terraform.tfvars
terraform apply

# Phase 2: Add EKS
echo 'enable_eks = true' >> terraform.tfvars
terraform apply

# Phase 3: Add databases
echo 'enable_postgres = true' >> terraform.tfvars
terraform apply
```

### **Rollback**
```bash
# Rollback specific module
./scripts/deploy-phases.sh dev rollback postgres

# Manual rollback
terraform apply -var="enable_postgres=false"
```

## 📚 **Documentation**

- [Gradual Deployment Guide](GRADUAL_DEPLOYMENT_GUIDE.md) - Comprehensive guide with examples
- [Deployment Script](scripts/deploy-phases.sh) - Automated deployment script
- [Example Configuration](environments/dev/terraform.tfvars.example) - Complete example with feature flags

This implementation provides a robust, maintainable solution for gradual infrastructure deployment while keeping the codebase clean and team-friendly. 