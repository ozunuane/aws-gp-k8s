# Feature Flag Quick Reference

## ⚠️ **WARNING: Feature Flags Destroy Resources**

**Changing `enable_module = true` to `enable_module = false` will destroy all resources in that module!**

## 🛡️ **Current Deletion Protection Status**

| Environment | PostgreSQL | MySQL | Status |
|-------------|------------|-------|--------|
| **Dev** | `deletion_protection = false` | `deletion_protection = false` | ⚠️ **Unprotected** |
| **Staging** | `deletion_protection = true` | `deletion_protection = true` | ✅ **Protected** |
| **Production** | `deletion_protection = true` | `deletion_protection = true` | ✅ **Protected** |

## 🚨 **Safe Feature Flag Changes**

### **Before Changing Any Feature Flag**

```bash
# 1. Always plan first
terraform plan -var="enable_postgres=false"

# 2. Review what will be destroyed (look for "-" symbols)
# 3. Only apply if you're sure
terraform apply -var="enable_postgres=false"
```

### **Using the Deployment Script (Recommended)**

```bash
# The script shows you the plan and asks for confirmation
./scripts/deploy-phases.sh dev phase4

# Rollback specific module
./scripts/deploy-phases.sh dev rollback postgres
```

## 🔧 **Quick Commands**

### **Check Current Status**
```bash
# See what resources are deployed
terraform state list | grep postgres

# See current feature flag values
grep "enable_" terraform.tfvars
```

### **Safe Disable/Enable**
```bash
# Disable PostgreSQL safely
terraform plan -var="enable_postgres=false" -out=disable-postgres.tfplan
terraform apply disable-postgres.tfplan

# Re-enable PostgreSQL
terraform apply -var="enable_postgres=true"
```

### **Emergency Recovery**
```bash
# If resources were accidentally destroyed
aws rds describe-db-instances --db-instance-identifier myapp-dev-postgres

# Restore from snapshot (if available)
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier myapp-dev-postgres-restored \
  --db-snapshot-identifier your-snapshot-id
```

## 📋 **Feature Flag Checklist**

Before changing any feature flag:

- [ ] **Backup Data** (if applicable)
- [ ] **Run `terraform plan`** and review
- [ ] **Check Dependencies** (other modules that depend on this)
- [ ] **Test in Dev First** (if possible)
- [ ] **Use Deployment Script** (for safety)
- [ ] **Inform Team** (if production)

## 🚀 **Environment-Specific Recommendations**

### **Development**
```hcl
# Allow deletion but be careful
deletion_protection = false
```

### **Staging**
```hcl
# Prevent accidental deletion
deletion_protection = true
```

### **Production**
```hcl
# Always prevent deletion
deletion_protection = true
multi_az = true
```

## 📞 **Emergency Contacts**

If you accidentally destroy resources:

1. **Stop immediately** - Don't run more commands
2. **Check AWS Console** - See if resources still exist
3. **Check Backups** - Look for automated snapshots
4. **Contact Team** - Inform DevOps/Infrastructure team
5. **Document** - Write down what happened

## 🔗 **Related Documentation**

- [Feature Flag Destruction Guide](FEATURE_FLAG_DESTRUCTION_GUIDE.md)
- [Gradual Deployment Guide](GRADUAL_DEPLOYMENT_GUIDE.md)
- [Deployment Script](../scripts/deploy-phases.sh)

---

**Remember: Always plan before applying!** 🛡️ 