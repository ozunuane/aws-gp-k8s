# Troubleshooting Guide

This guide provides solutions for common issues encountered when deploying and managing the AWS GP K8s infrastructure.

## 🔍 Common Issues

### Terraform Issues

#### Issue: State Lock Error
**Error**: `Error acquiring the state lock`

**Solution**:
```bash
# Check for stuck locks
terraform force-unlock LOCK_ID

# Or if you're sure no one else is running Terraform
terraform force-unlock -force LOCK_ID
```

#### Issue: Provider Version Conflicts
**Error**: `Provider version constraints are not satisfied`

**Solution**:
```bash
# Update providers
terraform init -upgrade

# Or specify exact versions in provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

#### Issue: Module Source Not Found
**Error**: `Module source not found`

**Solution**:
```bash
# Check module paths
ls -la modules/

# Update module source paths
terraform init -reconfigure

# Verify module structure
terraform validate
```

### VPC Endpoints Issues

#### Issue: S3 Access Failing Through VPC Endpoint
**Error**: `Access Denied` or `Connection Timeout`

**Diagnosis**:
```bash
# Check VPC endpoint status
aws ec2 describe-vpc-endpoints \
  --filters "Name=vpc-id,Values=vpc-xxxxxxxxx" "Name=service-name,Values=*.s3"

# Verify route table associations
aws ec2 describe-route-tables \
  --route-table-ids rtb-xxxxxxxxx

# Test S3 access
aws s3 ls --endpoint-url https://s3.us-west-2.amazonaws.com
```

**Solutions**:
1. **Check VPC Endpoint Policy**:
   ```bash
   aws ec2 describe-vpc-endpoints \
     --vpc-endpoint-ids vpce-xxxxxxxxx \
     --query 'VpcEndpoints[0].PolicyDocument'
   ```

2. **Verify Route Table Associations**:
   ```bash
   # Ensure S3 endpoint is associated with all route tables
   aws ec2 describe-vpc-endpoints \
     --vpc-endpoint-ids vpce-xxxxxxxxx \
     --query 'VpcEndpoints[0].RouteTableIds'
   ```

3. **Check Security Groups** (for interface endpoints):
   ```bash
   aws ec2 describe-security-groups \
     --group-ids sg-xxxxxxxxx
   ```

#### Issue: Interface Endpoint Not Responding
**Error**: `Connection refused` or `DNS resolution failed`

**Diagnosis**:
```bash
# Check endpoint status
aws ec2 describe-vpc-endpoints \
  --vpc-endpoint-ids vpce-xxxxxxxxx \
  --query 'VpcEndpoints[0].{State:State,DnsEntries:DnsEntries}'

# Test DNS resolution
nslookup vpce-xxxxxxxxx.s3.us-west-2.vpce.amazonaws.com
```

**Solutions**:
1. **Enable Private DNS**:
   ```bash
   aws ec2 modify-vpc-endpoint \
     --vpc-endpoint-id vpce-xxxxxxxxx \
     --private-dns-enabled
   ```

2. **Check Security Group Rules**:
   ```bash
   aws ec2 describe-security-groups \
     --group-ids sg-xxxxxxxxx \
     --query 'SecurityGroups[0].IpPermissions'
   ```

3. **Verify Subnet Associations**:
   ```bash
   aws ec2 describe-vpc-endpoints \
     --vpc-endpoint-ids vpce-xxxxxxxxx \
     --query 'VpcEndpoints[0].SubnetIds'
   ```

### EKS Issues

#### Issue: EKS Cluster Not Accessible
**Error**: `Unable to connect to the server`

**Diagnosis**:
```bash
# Check cluster status
aws eks describe-cluster --name cluster-name

# Verify kubeconfig
kubectl config current-context
kubectl config get-contexts
```

**Solutions**:
1. **Update kubeconfig**:
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name cluster-name
   ```

2. **Check IAM Permissions**:
   ```bash
   # Verify user/role has EKS permissions
   aws sts get-caller-identity
   aws eks list-clusters
   ```

3. **Check Security Groups**:
   ```bash
   aws ec2 describe-security-groups \
     --group-ids sg-xxxxxxxxx \
     --query 'SecurityGroups[0].IpPermissions'
   ```

#### Issue: Node Group Scaling Problems
**Error**: `Insufficient capacity` or nodes not joining cluster

**Diagnosis**:
```bash
# Check node group status
aws eks describe-nodegroup --cluster-name cluster-name --nodegroup-name nodegroup-name

# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names eks-nodegroup-name
```

**Solutions**:
1. **Check Instance Types**:
   ```bash
   # Verify instance types are available in your AZs
   aws ec2 describe-instance-type-offerings \
     --location-type availability-zone \
     --filters "Name=instance-type,Values=t3.medium"
   ```

2. **Check VPC Endpoints** (if using private subnets):
   ```bash
   # Ensure EKS endpoints are available
   aws ec2 describe-vpc-endpoints \
     --filters "Name=service-name,Values=*.eks"
   ```

### IAM Issues

#### Issue: Permission Denied Errors
**Error**: `Access Denied` or `Insufficient permissions`

**Diagnosis**:
```bash
# Check current identity
aws sts get-caller-identity

# Test specific permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT:user/USERNAME \
  --action-names s3:ListBucket
```

**Solutions**:
1. **Check IAM Policies**:
   ```bash
   aws iam get-user --user-name USERNAME
   aws iam list-attached-user-policies --user-name USERNAME
   ```

2. **Verify Role Assumptions**:
   ```bash
   aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/ROLE-NAME
   ```

3. **Check Trust Relationships**:
   ```bash
   aws iam get-role --role-name ROLE-NAME
   ```

### Network Issues

#### Issue: NAT Gateway Not Working
**Error**: `No route to host` from private subnets

**Diagnosis**:
```bash
# Check NAT Gateway status
aws ec2 describe-nat-gateways \
  --nat-gateway-ids nat-xxxxxxxxx

# Verify route tables
aws ec2 describe-route-tables \
  --route-table-ids rtb-xxxxxxxxx
```

**Solutions**:
1. **Check NAT Gateway State**:
   ```bash
   # Wait for NAT Gateway to be available
   aws ec2 wait nat-gateway-available --nat-gateway-ids nat-xxxxxxxxx
   ```

2. **Verify Route Table Configuration**:
   ```bash
   # Ensure private subnets route through NAT Gateway
   aws ec2 describe-route-tables \
     --route-table-ids rtb-xxxxxxxxx \
     --query 'RouteTables[0].Routes'
   ```

#### Issue: Security Group Rules Blocking Traffic
**Error**: `Connection timeout` or `Connection refused`

**Diagnosis**:
```bash
# Check security group rules
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxxx

# Test connectivity
telnet hostname port
```

**Solutions**:
1. **Add Required Rules**:
   ```bash
   aws ec2 authorize-security-group-ingress \
     --group-id sg-xxxxxxxxx \
     --protocol tcp \
     --port 443 \
     --cidr 10.0.0.0/16
   ```

2. **Check Source Security Groups**:
   ```bash
   # Verify source security group allows traffic
   aws ec2 describe-security-groups \
     --group-ids sg-source-xxxxxxxxx
   ```

## 🔧 Debugging Commands

### General Debugging

```bash
# Check Terraform state
terraform state list
terraform state show module.vpc.aws_vpc.main

# Validate configuration
terraform validate
terraform fmt -check

# Check provider versions
terraform version
terraform providers
```

### AWS Resource Debugging

```bash
# List all resources in VPC
aws ec2 describe-instances --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Check VPC endpoints
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Check EKS resources
aws eks list-clusters
aws eks describe-cluster --name cluster-name
aws eks list-nodegroups --cluster-name cluster-name
```

### Network Debugging

```bash
# Test connectivity from within VPC
kubectl run debug-pod --image=amazon/aws-cli --rm -it --restart=Never -- \
  aws s3 ls

# Test DNS resolution
kubectl run debug-pod --image=busybox --rm -it --restart=Never -- \
  nslookup s3.us-west-2.amazonaws.com

# Test network connectivity
kubectl run debug-pod --image=busybox --rm -it --restart=Never -- \
  wget -O- https://s3.us-west-2.amazonaws.com
```

## 📊 Monitoring and Logs

### CloudWatch Logs

```bash
# Check EKS cluster logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks"

# Get specific log events
aws logs filter-log-events \
  --log-group-name "/aws/eks/cluster-name/cluster" \
  --start-time $(date -d '1 hour ago' +%s)000
```

### VPC Flow Logs

```bash
# Enable VPC flow logs for debugging
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxxxxxxxx \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name vpc-flow-logs
```

### EKS Control Plane Logs

```bash
# Check EKS control plane logs
aws eks describe-cluster --name cluster-name \
  --query 'cluster.logging.clusterLogging[].types'
```

## 🚨 Emergency Procedures

### Rollback Terraform Changes

```bash
# Revert to previous state
terraform plan -out=rollback.tfplan
terraform apply rollback.tfplan

# Or destroy and recreate
terraform destroy -target=module.vpc
terraform apply
```

### Emergency Access

```bash
# Create emergency IAM user
aws iam create-user --user-name emergency-admin
aws iam attach-user-policy \
  --user-name emergency-admin \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create access keys
aws iam create-access-key --user-name emergency-admin
```

### Data Recovery

```bash
# Restore from S3 backup
aws s3 cp s3://bucket/backup/state.tfstate ./state.tfstate

# Import state
terraform import -state=state.tfstate module.vpc.aws_vpc.main vpc-xxxxxxxxx
```

## 📞 Support Resources

### AWS Support

- **AWS Documentation**: [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- **AWS Support**: [Create Support Case](https://console.aws.amazon.com/support/home)
- **AWS Health Dashboard**: [Service Status](https://status.aws.amazon.com/)

### Community Resources

- **Terraform Documentation**: [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **EKS Best Practices**: [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- **Karpenter Documentation**: [Karpenter.sh](https://karpenter.sh/)

### Internal Resources

- **VPC Endpoints Documentation**: [docs/vpc-endpoints.md](vpc-endpoints.md)
- **Deployment Guide**: [docs/deployment-guide.md](deployment-guide.md)
- **Architecture Documentation**: [README.md](../README.md)

---

**Note**: Always document any issues and solutions for future reference. Consider creating runbooks for common procedures. 