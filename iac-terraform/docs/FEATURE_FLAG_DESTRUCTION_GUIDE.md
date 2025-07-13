# Feature Flag Destruction Guide

This guide explains what happens when you change feature flags from `true` to `false` and how to prevent unwanted resource destruction.

## ⚠️ **Important: Feature Flags and Resource Destruction**

**Yes, changing a feature flag from `true` to `false` will destroy the resources created by that module.**

This is because Terraform uses `count = var.enable_module ? 1 : 0`, and when the count becomes 0, Terraform removes the resources from its state and destroys them.

## 🔄 **What Happens When You Change `enable_postgres = true` to `enable_postgres = false`**

### **Terraform Plan Output**
```bash
$ terraform plan -var="enable_postgres=false"

# You'll see something like this:
- module.postgres[0].aws_db_instance.main
- module.postgres[0].aws_db_subnet_group.main
- module.postgres[0].aws_security_group.main
- module.postgres[0].aws_ssm_parameter.password
- module.postgres[0].aws_db_parameter_group.main
- module.postgres[0].random_password.postgres_password
```

### **Terraform Apply**
```bash
$ terraform apply -var="enable_postgres=false"

# This will destroy ALL PostgreSQL resources:
# - RDS instance and all data
# - Security groups
# - Subnet groups
# - Parameter groups
# - SSM parameters
# - Random passwords
```

## 🛡️ **How to Prevent Unwanted Destruction**

### **Option 1: Use Deletion Protection (Recommended)**

#### **For RDS Databases**
Set `deletion_protection = true` in your configuration:

```hcl
# environments/dev/main.tf
module "postgres" {
  # ... other configuration ...
  
  # Multi-AZ and Deletion Protection
  multi_az            = false
  deletion_protection = true  # ← This prevents accidental deletion
  
  # ... rest of configuration ...
}
```

#### **For Production Environments**
Always enable deletion protection in production:

```hcl
# environments/prod/main.tf
module "postgres" {
  # ... other configuration ...
  
  # Multi-AZ and Deletion Protection
  multi_az            = true
  deletion_protection = true  # ← Always true in production
  
  # ... rest of configuration ...
}
```

### **Option 2: Use `prevent_destroy` Lifecycle Rule**

Add lifecycle rules to critical resources in your modules:

```hcl
# modules/rds-postgres/main.tf
resource "aws_db_instance" "postgres" {
  # ... configuration ...
  
  lifecycle {
    prevent_destroy = true  # ← Prevents Terraform from destroying this resource
  }
}
```

### **Option 3: Use `-target` for Selective Deployment**

Instead of disabling the entire module, use `-target` to deploy specific resources:

```bash
# Deploy only specific resources instead of disabling the module
terraform apply -target=module.postgres.aws_db_instance.postgres
```

### **Option 4: Use Data Sources for Existing Resources**

If you want to keep existing resources but disable the module:

```hcl
# variables.tf
variable "existing_postgres_endpoint" {
  description = "Existing PostgreSQL endpoint (when enable_postgres is false)"
  type        = string
  default     = null
}

# main.tf
locals {
  postgres_endpoint = var.enable_postgres ? module.postgres[0].endpoint : var.existing_postgres_endpoint
}
```

## 🚨 **Emergency Recovery Options**

### **If Resources Were Accidentally Destroyed**

#### **1. Check AWS Console**
- Go to AWS RDS Console
- Check if the database still exists
- Look for any automated backups

#### **2. Restore from Snapshot**
```bash
# If you have automated backups enabled
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier myapp-dev-postgres-restored \
  --db-snapshot-identifier your-snapshot-identifier
```

#### **3. Restore from Point-in-Time**
```bash
# If you have automated backups enabled
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier myapp-dev-postgres \
  --target-db-instance-identifier myapp-dev-postgres-restored \
  --restore-time 2024-01-15T10:00:00Z
```

## 📋 **Best Practices**

### **1. Environment-Specific Deletion Protection**

```hcl
# environments/dev/main.tf
module "postgres" {
  # ... configuration ...
  deletion_protection = false  # Allow deletion in dev
}

# environments/staging/main.tf
module "postgres" {
  # ... configuration ...
  deletion_protection = true   # Prevent deletion in staging
}

# environments/prod/main.tf
module "postgres" {
  # ... configuration ...
  deletion_protection = true   # Always prevent deletion in prod
}
```

### **2. Use Terraform Workspaces for Testing**

```bash
# Create a test workspace
terraform workspace new test-feature-flags

# Test your changes safely
terraform plan -var="enable_postgres=false"

# If everything looks good, apply
terraform apply -var="enable_postgres=false"

# Switch back to main workspace
terraform workspace select default
```

### **3. Use `terraform plan` Before `terraform apply`**

Always run `terraform plan` first to see what will be destroyed:

```bash
# Always plan first
terraform plan -var="enable_postgres=false"

# Review the output carefully
# Look for resources marked with "-" (to be destroyed)

# Only apply if you're sure
terraform apply -var="enable_postgres=false"
```

### **4. Use the Deployment Script**

The deployment script includes safety checks:

```bash
# Use the script which shows what will be deployed/destroyed
./scripts/deploy-phases.sh dev phase4

# The script will show you the plan and ask for confirmation
```

## 🔧 **Safe Feature Flag Management**

### **Step-by-Step Process**

#### **1. Plan First**
```bash
cd environments/dev
terraform plan -var="enable_postgres=false" -out=disable-postgres.tfplan
```

#### **2. Review the Plan**
Carefully review what will be destroyed:
- Check for data loss warnings
- Verify no critical resources are being removed
- Ensure you have backups if needed

#### **3. Apply with Caution**
```bash
# Only apply if you're absolutely sure
terraform apply disable-postgres.tfplan
```

#### **4. Verify the Results**
```bash
# Check that resources are gone
terraform state list | grep postgres

# Should return empty or only show data sources
```

## 📊 **Feature Flag Safety Checklist**

Before changing any feature flag from `true` to `false`:

- [ ] **Backup Data**: Ensure all data is backed up
- [ ] **Check Dependencies**: Verify no other resources depend on this module
- [ ] **Review Plan**: Run `terraform plan` and review carefully
- [ ] **Test in Non-Prod**: Test the change in dev/staging first
- [ ] **Use Deletion Protection**: Enable deletion protection for critical resources
- [ ] **Document Changes**: Document what you're doing and why
- [ ] **Team Communication**: Inform team members of the change

## 🚀 **Recommended Approach**

### **For Development Environments**
```hcl
# Allow deletion but use the deployment script
deletion_protection = false
```

### **For Staging Environments**
```hcl
# Prevent accidental deletion
deletion_protection = true
```

### **For Production Environments**
```hcl
# Always prevent deletion
deletion_protection = true
multi_az = true
```

## 🔄 **Rollback Strategy**

If you accidentally disable a module and need to re-enable it:

```bash
# Re-enable the module
terraform apply -var="enable_postgres=true"

# Terraform will recreate the resources
# Note: Data will be lost unless you have backups
```

## 📚 **Related Documentation**

- [Gradual Deployment Guide](GRADUAL_DEPLOYMENT_GUIDE.md)
- [Deployment Strategies](DEPLOYMENT_STRATEGIES.md)
- [RDS PostgreSQL Module](../modules/rds-postgres/README.md)
- [RDS MySQL Module](../modules/rds-mysql/README.md)

Remember: **Always plan before applying, and use deletion protection for critical resources!** 