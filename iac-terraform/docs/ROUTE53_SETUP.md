# Route53 Setup Guide

This guide explains the different options for setting up Route53 hosted zones with your infrastructure.

## Option 1: Automatic Route53 Creation (Recommended)

**What happens:** Terraform automatically creates Route53 hosted zones for your domains.

### Configuration

In your `terraform.tfvars` file, **leave the Route53 zone IDs as `null`**:

```hcl
# Domain and SSL Configuration
primary_domain = "yourdomain.com"
primary_route53_zone_id = null  # Terraform will create this automatically

secondary_domain = "yourdomain2.com"
secondary_route53_zone_id = null  # Terraform will create this automatically
```

### What Terraform Does

1. **Creates Route53 hosted zones** for each domain
2. **Generates SSL certificates** with DNS validation
3. **Adds validation records** automatically
4. **Outputs nameservers** for you to configure at your domain registrar

### After Deployment

1. **Get the nameservers** from Terraform outputs:
   ```bash
   terraform output hosted_zone_nameservers
   ```

2. **Update your domain registrar** with the nameservers:
   - Go to your domain registrar (GoDaddy, Namecheap, etc.)
   - Find DNS/Nameserver settings
   - Replace existing nameservers with the ones from Terraform output

### Example Output
```bash
hosted_zone_nameservers = {
  "primary" = [
    "ns-1234.awsdns-12.com",
    "ns-567.awsdns-34.net",
    "ns-890.awsdns-56.org",
    "ns-123.awsdns-78.co.uk"
  ]
  "secondary" = [
    "ns-456.awsdns-12.com",
    "ns-789.awsdns-34.net",
    "ns-012.awsdns-56.org",
    "ns-345.awsdns-78.co.uk"
  ]
}
```

## Option 2: Manual Route53 Creation

**What happens:** You create Route53 hosted zones manually and provide the zone IDs.

### Step 1: Create Hosted Zones Manually

1. Go to AWS Route53 Console
2. Click "Hosted zones" → "Create hosted zone"
3. Enter your domain name (e.g., `yourdomain.com`)
4. Click "Create hosted zone"
5. Note the hosted zone ID (e.g., `Z1234567890ABC`)

### Step 2: Update Nameservers

1. Copy the nameservers from the hosted zone
2. Go to your domain registrar
3. Update the nameservers to point to Route53

### Step 3: Configure Terraform

In your `terraform.tfvars` file:

```hcl
# Domain and SSL Configuration
primary_domain = "yourdomain.com"
primary_route53_zone_id = "Z1234567890ABC"  # Your manual hosted zone ID

secondary_domain = "yourdomain2.com"
secondary_route53_zone_id = "Z0987654321XYZ"  # Your manual hosted zone ID
```

## Option 3: Hybrid Approach

**What happens:** Some domains use existing hosted zones, others are created automatically.

### Configuration

```hcl
# Domain and SSL Configuration
primary_domain = "yourdomain.com"
primary_route53_zone_id = "Z1234567890ABC"  # Existing hosted zone

secondary_domain = "yourdomain2.com"
secondary_route53_zone_id = null  # Terraform will create this
```

## Cost Comparison

| Option | Route53 Hosted Zone Cost | Setup Effort |
|--------|-------------------------|--------------|
| **Automatic** | ~$0.50/month per zone | **Low** (just update nameservers) |
| **Manual** | ~$0.50/month per zone | **Medium** (create zones + update nameservers) |
| **Hybrid** | ~$0.50/month per zone | **Variable** |

## DNS Propagation

After updating nameservers:
- **Initial propagation**: 15-30 minutes
- **Full propagation**: Up to 48 hours
- **SSL certificate validation**: Usually completes within 1-2 hours

## Troubleshooting

### Nameserver Issues

1. **Check nameservers are correct**:
   ```bash
   nslookup -type=ns yourdomain.com
   ```

2. **Verify propagation**:
   ```bash
   dig yourdomain.com NS
   ```

### Certificate Validation Issues

1. **Check DNS records exist**:
   ```bash
   dig _acme-challenge.yourdomain.com TXT
   ```

2. **Verify hosted zone configuration**:
   - Ensure hosted zone name matches domain exactly
   - Check that validation records are present

### Common Issues

1. **Wrong nameservers**: Make sure you're using the Route53 nameservers, not your registrar's
2. **Domain mismatch**: Hosted zone name must match domain exactly
3. **Propagation delay**: Wait up to 48 hours for full DNS propagation

## Best Practices

1. **Use automatic creation** for new domains
2. **Use existing zones** for domains already in Route53
3. **Monitor certificate status** after deployment
4. **Set up DNS monitoring** for critical domains
5. **Document your DNS setup** for team reference

## Next Steps

After Route53 setup:

1. **Deploy your infrastructure**:
   ```bash
   terraform plan
   terraform apply
   ```

2. **Verify SSL certificates**:
   ```bash
   terraform output ssl_certificate_statuses
   ```

3. **Test your domains**:
   ```bash
   curl -I https://dev.yourdomain.com
   ```

4. **Set up monitoring** for certificate expiration and DNS health 