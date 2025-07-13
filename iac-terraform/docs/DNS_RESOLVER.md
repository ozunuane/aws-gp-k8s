# DNS Resolver Module Documentation

This guide explains how to configure Route53 Resolver for your VPC to handle both internal and external DNS resolution.

## Overview

The DNS Resolver module provides:
- **Outbound Resolver Endpoint**: Forwards DNS queries to external DNS servers
- **Inbound Resolver Endpoint**: Handles DNS queries from external sources
- **Resolver Rules**: Custom DNS routing for specific domains
- **Security Groups**: Proper network access control for resolver endpoints

## Configuration via tfvars

The DNS resolver is configured through `terraform.tfvars` for easy customization:

```hcl
# In terraform.tfvars
dns_resolver_config = {
  # Enable both inbound and outbound resolvers
  enable_outbound_resolver = true
  enable_inbound_resolver  = true

  # Outbound resolver rules (forward specific domains to external DNS)
  resolver_rules = {
    "corporate-dns" = {
      domain_name = "corporate.example.com"
      name        = "corporate-dns-forward"
      target_ips  = ["8.8.8.8", "8.8.4.4"]
    },
    "partner-dns" = {
      domain_name = "partner.example.com"
      name        = "partner-dns-forward"
      target_ips  = ["1.1.1.1", "1.0.0.1"]
    }
  }

  # Inbound resolver rules (for internal domains)
  inbound_resolver_rules = {
    "internal-domain" = {
      domain_name = "internal.example.com"
      name        = "internal-domain-resolver"
    }
  }
}
```

## Architecture

```
Internet
    │
    ├── Public Hosted Zones (example.com)
    │   └── External Load Balancer
    │
    ├── Private Hosted Zones (internal.example.com)
    │   └── Internal Load Balancer
    │
    └── DNS Resolver Endpoints
        ├── Outbound (forwards to external DNS)
        └── Inbound (handles internal queries)
```

## Configuration Options

### DNS Resolver Configuration

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `enable_outbound_resolver` | bool | No | Enable outbound resolver endpoint |
| `enable_inbound_resolver` | bool | No | Enable inbound resolver endpoint |
| `resolver_rules` | map | No | Outbound resolver rules for domain forwarding |
| `inbound_resolver_rules` | map | No | Inbound resolver rules for internal domains |

### Resolver Rules Configuration

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `domain_name` | string | Yes | Domain to forward/resolve |
| `name` | string | Yes | Name of the resolver rule |
| `target_ips` | list(string) | Yes* | Target DNS servers (required for outbound) |

## Use Cases

### 1. Corporate DNS Integration

Forward specific domains to your corporate DNS servers:

```hcl
resolver_rules = {
  "corporate" = {
    domain_name = "corporate.company.com"
    name        = "corporate-dns"
    target_ips  = ["10.0.1.10", "10.0.1.11"]
  }
}
```

### 2. Partner DNS Integration

Forward partner domains to their DNS servers:

```hcl
resolver_rules = {
  "partner" = {
    domain_name = "partner.example.com"
    name        = "partner-dns"
    target_ips  = ["203.0.113.10", "203.0.113.11"]
  }
}
```

### 3. Internal Domain Resolution

Handle internal domain resolution within your VPC:

```hcl
inbound_resolver_rules = {
  "internal" = {
    domain_name = "internal.example.com"
    name        = "internal-resolver"
  }
}
```

## Advanced Configuration Examples

### Multiple Environment Configuration

```hcl
# Development Environment
dns_resolver_config = {
  enable_outbound_resolver = true
  enable_inbound_resolver  = true
  resolver_rules = {
    "dev-dns" = {
      domain_name = "dev.example.com"
      name        = "dev-dns-forward"
      target_ips  = ["8.8.8.8", "8.8.4.4"]
    }
  }
  inbound_resolver_rules = {
    "dev-internal" = {
      domain_name = "internal.dev.example.com"
      name        = "dev-internal-resolver"
    }
  }
}

# Production Environment
dns_resolver_config = {
  enable_outbound_resolver = true
  enable_inbound_resolver  = true
  resolver_rules = {
    "corporate-dns" = {
      domain_name = "corporate.company.com"
      name        = "corporate-dns"
      target_ips  = ["10.0.1.10", "10.0.1.11"]
    },
    "partner-dns" = {
      domain_name = "partner.example.com"
      name        = "partner-dns"
      target_ips  = ["203.0.113.10", "203.0.113.11"]
    }
  }
  inbound_resolver_rules = {
    "prod-internal" = {
      domain_name = "internal.example.com"
      name        = "prod-internal-resolver"
    }
  }
}
```

### Complex DNS Routing

```hcl
dns_resolver_config = {
  enable_outbound_resolver = true
  enable_inbound_resolver  = true
  
  resolver_rules = {
    # Corporate domains
    "corporate" = {
      domain_name = "corporate.company.com"
      name        = "corporate-dns"
      target_ips  = ["10.0.1.10", "10.0.1.11"]
    },
    
    # Partner domains
    "partner" = {
      domain_name = "partner.example.com"
      name        = "partner-dns"
      target_ips  = ["203.0.113.10", "203.0.113.11"]
    },
    
    # Development domains
    "dev" = {
      domain_name = "dev.example.com"
      name        = "dev-dns"
      target_ips  = ["8.8.8.8", "8.8.4.4"]
    },
    
    # Staging domains
    "staging" = {
      domain_name = "staging.example.com"
      name        = "staging-dns"
      target_ips  = ["1.1.1.1", "1.0.0.1"]
    }
  }
  
  inbound_resolver_rules = {
    # Internal domains
    "internal" = {
      domain_name = "internal.example.com"
      name        = "internal-resolver"
    },
    
    # Database domains
    "database" = {
      domain_name = "database.example.com"
      name        = "database-resolver"
    },
    
    # Monitoring domains
    "monitoring" = {
      domain_name = "monitoring.example.com"
      name        = "monitoring-resolver"
    }
  }
}
```

## Security

### Security Groups

The module creates a security group with:

**Outbound Rules:**
- UDP 53 → 0.0.0.0/0 (DNS queries)
- TCP 53 → 0.0.0.0/0 (DNS queries)

**Inbound Rules:**
- UDP 53 ← VPC CIDR (DNS queries from VPC)
- TCP 53 ← VPC CIDR (DNS queries from VPC)

### Network Placement

- Resolver endpoints are placed in private subnets
- No direct internet access (uses NAT Gateway)
- Traffic flows through VPC endpoints for AWS services

## Integration with ACM Module

The DNS resolver works seamlessly with the ACM module:

```hcl
# ACM module with private domains
module "acm" {
  source = "../../modules/acm"

  domains = {
    public = {
      domain_name = "example.com"
      hosted_zone_type = "public"
      load_balancer_type = "external"
      # ... other config
    }
    private = {
      domain_name = "internal.example.com"
      hosted_zone_type = "private"
      vpc_id = module.vpc.vpc_id
      load_balancer_type = "internal"
      # ... other config
    }
  }

  # Load balancer configuration
  load_balancer_dns_name = module.ingress.external_load_balancer_hostname
  load_balancer_zone_id  = module.ingress.external_load_balancer_zone_id
  
  internal_load_balancer_dns_name = module.ingress.internal_load_balancer_hostname
  internal_load_balancer_zone_id  = module.ingress.internal_load_balancer_zone_id
}
```

## Outputs

### Resolver Endpoints

```hcl
output "outbound_resolver_endpoint_id" {
  value = module.dns_resolver.outbound_resolver_endpoint_id
}

output "inbound_resolver_endpoint_id" {
  value = module.dns_resolver.inbound_resolver_endpoint_id
}
```

### Resolver IPs

```hcl
output "outbound_resolver_endpoint_ips" {
  value = module.dns_resolver.outbound_resolver_endpoint_ips
}

output "inbound_resolver_endpoint_ips" {
  value = module.dns_resolver.inbound_resolver_endpoint_ips
}
```

### Security Group

```hcl
output "resolver_security_group_id" {
  value = module.dns_resolver.resolver_security_group_id
}
```

## Testing DNS Resolution

### From Within VPC

```bash
# Test internal domain resolution
nslookup api.internal.example.com

# Test external domain resolution
nslookup www.example.com

# Test corporate domain forwarding
nslookup service.corporate.company.com
```

### From External

```bash
# Test public domain resolution
nslookup www.example.com

# Internal domains should not resolve externally
nslookup api.internal.example.com  # Should fail
```

## Troubleshooting

### Common Issues

1. **DNS Resolution Failing**
   - Check security group rules
   - Verify resolver endpoints are in private subnets
   - Ensure NAT Gateway is configured

2. **Private Domain Not Resolving**
   - Verify private hosted zone is associated with VPC
   - Check inbound resolver rules
   - Ensure DNS queries are coming from VPC

3. **External Domain Forwarding Not Working**
   - Check outbound resolver rules in tfvars
   - Verify target DNS servers are reachable
   - Ensure outbound resolver endpoint is enabled

### Debugging Commands

```bash
# Check resolver endpoints
aws route53resolver list-resolver-endpoints

# Check resolver rules
aws route53resolver list-resolver-rules

# Test DNS resolution
dig @resolver-ip domain.com
```

## Best Practices

1. **Configuration Management**: Use tfvars for easy configuration changes
2. **Redundancy**: Use multiple target DNS servers for outbound rules
3. **Security**: Restrict security group rules to specific CIDR blocks
4. **Monitoring**: Set up CloudWatch alarms for resolver endpoints
5. **Documentation**: Document all custom DNS routing rules in tfvars
6. **Testing**: Test DNS resolution from both internal and external sources

## Cost Considerations

- **Resolver Endpoints**: ~$0.10 per endpoint per hour
- **Resolver Rules**: ~$0.50 per rule per month
- **DNS Queries**: Standard Route53 pricing applies

## Migration from Existing DNS

1. **Create resolver endpoints** in new VPC
2. **Configure resolver rules** in tfvars for custom domains
3. **Update DHCP options** to use resolver endpoints
4. **Test DNS resolution** thoroughly
5. **Update applications** to use new internal domains 