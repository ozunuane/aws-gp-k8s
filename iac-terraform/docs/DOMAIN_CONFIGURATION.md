# Domain Configuration Guide

This guide explains how to configure domains, SSL certificates, and DNS records for your AWS EKS infrastructure using the ACM module.

## Overview

The ACM module supports:
- Multiple domains with individual SSL certificates
- Specific subdomains (e.g., `www.example.com`, `api.example.com`)
- **Wildcard subdomains** (e.g., `*.api.example.com`, `*.app.example.com`)
- Automatic Route53 hosted zone creation
- Automatic DNS record creation (A and CNAME records)
- Integration with existing Route53 zones

## Domain Configuration Structure

```hcl
domains = {
  primary = {
    domain_name = "example.com"
    subdomains = ["www", "api", "app", "dev"]
    wildcard_subdomains = ["api", "app"]  # Creates *.api.example.com and *.app.example.com
    route53_zone_id = null
    create_hosted_zone = true
    a_records = [
      {
        name = "dev.example.com"
        type = "A"
        ttl = 300
      }
    ]
    cname_records = [
      {
        name = "www.dev.example.com"
        value = "dev.example.com"
        ttl = 300
      }
    ]
  }
}
```

## Configuration Options

### Domain Configuration

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `domain_name` | string | Yes | The main domain name (e.g., "example.com") |
| `subdomains` | list(string) | No | List of specific subdomains to include in the certificate |
| `wildcard_subdomains` | list(string) | No | List of subdomains to create wildcard certificates for |
| `route53_zone_id` | string | No | Existing Route53 zone ID (null for auto-creation) |
| `create_hosted_zone` | bool | No | Whether to create a new Route53 hosted zone |
| `a_records` | list(object) | No | List of A records to create |
| `cname_records` | list(object) | No | List of CNAME records to create |

### Wildcard Subdomains

The `wildcard_subdomains` feature allows you to create certificates that cover all subdomains under a specific subdomain. For example:

```hcl
wildcard_subdomains = ["api", "app"]
```

This creates certificates for:
- `*.api.example.com` - covers any subdomain under api.example.com
- `*.app.example.com` - covers any subdomain under app.example.com

**Examples of what these wildcards cover:**
- `*.api.example.com` covers: `v1.api.example.com`, `v2.api.example.com`, `beta.api.example.com`, etc.
- `*.app.example.com` covers: `web.app.example.com`, `mobile.app.example.com`, `admin.app.example.com`, etc.

### DNS Records

#### A Records
```hcl
a_records = [
  {
    name = "dev.example.com"    # Full domain name
    type = "A"                  # Record type
    ttl = 300                   # Time to live in seconds
  }
]
```

#### CNAME Records
```hcl
cname_records = [
  {
    name = "www.dev.example.com"     # Full domain name
    value = "dev.example.com"        # Target domain
    ttl = 300                        # Time to live in seconds
  }
]
```

## Examples

### Basic Configuration with Wildcards

```hcl
domains = {
  primary = {
    domain_name = "myapp.com"
    subdomains = ["www", "api", "admin"]
    wildcard_subdomains = ["api"]  # Creates *.api.myapp.com
    route53_zone_id = null
    create_hosted_zone = true
    a_records = [
      {
        name = "dev.myapp.com"
        type = "A"
        ttl = 300
      }
    ]
    cname_records = []
  }
}
```

**Resulting certificates:**
- `myapp.com` (main domain)
- `www.myapp.com`
- `api.myapp.com`
- `admin.myapp.com`
- `*.api.myapp.com` (wildcard)

### Multiple Wildcard Subdomains

```hcl
domains = {
  primary = {
    domain_name = "example.com"
    subdomains = ["www", "api", "app", "dev"]
    wildcard_subdomains = ["api", "app", "services"]
    route53_zone_id = null
    create_hosted_zone = true
    a_records = [
      {
        name = "dev.example.com"
        type = "A"
        ttl = 300
      }
    ]
    cname_records = []
  }
}
```

**Resulting certificates:**
- `example.com` (main domain)
- `www.example.com`
- `api.example.com`
- `app.example.com`
- `dev.example.com`
- `*.api.example.com` (wildcard)
- `*.app.example.com` (wildcard)
- `*.services.example.com` (wildcard)

### Using Existing Route53 Zone

```hcl
domains = {
  existing = {
    domain_name = "existing-domain.com"
    subdomains = ["www", "api"]
    wildcard_subdomains = ["api"]
    route53_zone_id = "Z1234567890ABC"  # Existing zone ID
    create_hosted_zone = false
    a_records = [
      {
        name = "app.existing-domain.com"
        type = "A"
        ttl = 300
      }
    ]
    cname_records = []
  }
}
```

## Integration with Ingress Controllers

The ACM module outputs certificate ARNs that can be used with your ingress controllers:

```hcl
module "ingress" {
  source = "../modules/ingress"
  
  environment = "dev"
  ssl_certificate_arn = module.acm.certificate_arns["primary"]
  
  # ... other configuration
}
```

## Best Practices

1. **Wildcard Usage**: Use wildcard subdomains for areas where you expect many subdomains (e.g., API versions, microservices)
2. **Security**: Wildcard certificates are convenient but consider security implications for sensitive subdomains
3. **Cost**: Each certificate (including wildcards) incurs AWS ACM costs
4. **Validation**: DNS validation is used for all certificates, requiring Route53 access
5. **TTL**: Use appropriate TTL values for your DNS records (300 seconds is common for dev, 3600 for production)

## Troubleshooting

### Certificate Validation Issues
- Ensure Route53 zone exists and is accessible
- Check that DNS validation records are created correctly
- Verify domain ownership and DNS propagation

### Wildcard Certificate Limitations
- Wildcard certificates only cover one level of subdomain
- `*.api.example.com` does NOT cover `api.example.com` (you need both)
- Wildcard certificates cannot be used for the root domain

### DNS Record Issues
- Ensure A records point to valid load balancer endpoints
- Check CNAME record targets exist and are accessible
- Verify TTL values are appropriate for your use case 