# SSL Certificate Setup Guide

This guide explains how to set up SSL certificates for your ingress controllers using AWS Certificate Manager (ACM) with support for multiple domains.

## Prerequisites

1. **Domain Names**: You need registered domain names
2. **Route53 Hosted Zones**: Your domains should be managed in Route53
3. **AWS Account**: Access to AWS Certificate Manager

## Option 1: Multiple Domains with ACM - Recommended

### Step 1: Create Route53 Hosted Zones

For each domain you want to use:

1. Go to AWS Route53 Console
2. Click "Hosted zones" → "Create hosted zone"
3. Enter your domain name (e.g., `yourdomain.com`, `yourdomain2.com`)
4. Click "Create hosted zone"
5. Note the hosted zone ID (e.g., `Z1234567890ABC`)

### Step 2: Update Your Domains' Nameservers

For each domain:
1. Go to your domain registrar (where you bought the domain)
2. Update the nameservers to point to the Route53 nameservers
3. The nameservers are listed in your Route53 hosted zone

### Step 3: Configure Terraform Variables

Update your environment's `terraform.tfvars` file:

```hcl
# Domain and SSL Configuration
primary_domain = "yourdomain.com"  # Replace with your actual primary domain
primary_route53_zone_id = "Z1234567890ABC"  # Replace with your primary Route53 hosted zone ID

secondary_domain = "yourdomain2.com"  # Replace with your actual secondary domain
secondary_route53_zone_id = "Z0987654321XYZ"  # Replace with your secondary Route53 hosted zone ID

# Add more domains as needed
# tertiary_domain = "yourdomain3.com"
# tertiary_route53_zone_id = "Z555666777888"
```

### Step 4: Configure ACM Module

In your environment's `main.tf`:

```hcl
module "acm" {
  source = "../../modules/acm"

  environment = local.environment
  
  # Multiple domains configuration
  domains = {
    primary = {
      domain_name = "dev.${var.primary_domain}"
      subject_alternative_names = [
        "*.dev.${var.primary_domain}",
        "api.dev.${var.primary_domain}"
      ]
      validation_method = "DNS"
      route53_zone_id   = var.primary_route53_zone_id
      use_existing_certificate = false
    }
    
    secondary = {
      domain_name = "dev.${var.secondary_domain}"
      subject_alternative_names = [
        "*.dev.${var.secondary_domain}",
        "api.dev.${var.secondary_domain}"
      ]
      validation_method = "DNS"
      route53_zone_id   = var.secondary_route53_zone_id
      use_existing_certificate = false
    }
    
    # Add more domains as needed
    # tertiary = {
    #   domain_name = "dev.${var.tertiary_domain}"
    #   subject_alternative_names = [
    #     "*.dev.${var.tertiary_domain}",
    #     "api.dev.${var.tertiary_domain}"
    #   ]
    #   validation_method = "DNS"
    #   route53_zone_id   = var.tertiary_route53_zone_id
    #   use_existing_certificate = false
    # }
  }

  tags = local.tags
}
```

### Step 5: Deploy the Infrastructure

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

The ACM module will:
- Create SSL certificates for each domain
- Add DNS validation records to Route53 for each domain
- Validate the certificates automatically

## Option 2: Use Existing Certificates

If you already have SSL certificates:

1. Go to AWS Certificate Manager
2. Import your existing certificates
3. Update the ACM module configuration:

```hcl
domains = {
  existing = {
    domain_name = "dev.yourdomain.com"
    subject_alternative_names = []
    validation_method = "DNS"
    route53_zone_id   = "Z1234567890ABC"
    use_existing_certificate = true
  }
}
```

## Option 3: Self-Signed Certificates (Development Only)

For development environments, you can use self-signed certificates:

1. Disable SSL termination in the ingress module
2. Use HTTP for development
3. Configure SSL at the application level if needed

## Certificate Domains

The ACM module creates certificates for each domain with:

- **Primary Domain**: `dev.yourdomain.com`
- **Wildcard**: `*.dev.yourdomain.com`
- **API Subdomain**: `api.dev.yourdomain.com`

## Environment-Specific Domains

| Environment | Primary Domain | Secondary Domain | Example |
|-------------|----------------|------------------|---------|
| Development | `dev.yourdomain.com` | `dev.yourdomain2.com` | `dev.example.com` |
| Staging | `staging.yourdomain.com` | `staging.yourdomain2.com` | `staging.example.com` |
| Production | `yourdomain.com` | `yourdomain2.com` | `example.com` |

## Using Multiple Certificates with Ingress

### Option 1: Use Primary Certificate (Default)
```hcl
module "ingress" {
  # ... other configuration ...
  
  ssl_certificate_arn = module.acm.primary_certificate_arn
  
  # ... rest of configuration ...
}
```

### Option 2: Use Specific Certificate
```hcl
module "ingress" {
  # ... other configuration ...
  
  ssl_certificate_arn = module.acm.certificate_arns["secondary"]
  
  # ... rest of configuration ...
}
```

### Option 3: Multiple Ingress Controllers
```hcl
# Primary ingress with primary certificate
module "ingress_primary" {
  # ... configuration ...
  ssl_certificate_arn = module.acm.certificate_arns["primary"]
}

# Secondary ingress with secondary certificate
module "ingress_secondary" {
  # ... configuration ...
  ssl_certificate_arn = module.acm.certificate_arns["secondary"]
}
```

## Troubleshooting

### Certificate Validation Fails

1. Check that your domains' nameservers point to Route53
2. Verify the Route53 hosted zone IDs are correct
3. Wait for DNS propagation (can take up to 48 hours)

### Certificate Not Found

1. Check the certificates exist in ACM
2. Verify the domain names match exactly
3. Ensure the certificates are in the same region as your EKS cluster

### Load Balancer SSL Issues

1. Check the certificate ARN is correctly passed to the ingress module
2. Verify the certificates are valid and not expired
3. Check the load balancer security groups allow HTTPS traffic

## Cost Considerations

- **ACM Certificates**: Free for public certificates
- **Route53 Hosted Zone**: ~$0.50/month per hosted zone
- **Route53 DNS Queries**: ~$0.40 per million queries

## Security Best Practices

1. **Use Private Certificates**: For internal services
2. **Enable Certificate Transparency**: For public certificates
3. **Rotate Certificates**: Set up automatic renewal
4. **Monitor Expiration**: Set up alerts for certificate expiration
5. **Limit Subject Alternative Names**: Only include necessary subdomains

## Outputs

The ACM module provides these outputs:

```hcl
output "certificate_arns" {
  description = "Map of domain names to certificate ARNs"
  value       = module.acm.certificate_arns
}

output "primary_certificate_arn" {
  description = "ARN of the primary certificate"
  value       = module.acm.primary_certificate_arn
}

output "certificate_statuses" {
  description = "Map of domain names to certificate statuses"
  value       = module.acm.certificate_statuses
}
```

## Next Steps

After setting up SSL certificates:

1. Configure your DNS to point to the load balancer
2. Test HTTPS access to your applications
3. Set up monitoring for certificate expiration
4. Configure automatic certificate renewal
5. Set up alerts for certificate validation failures 