# Example DNS Resolver Configuration via tfvars
# This shows how to configure DNS resolver rules through terraform.tfvars

# In your terraform.tfvars file:

dns_resolver_config = {
  # Enable both inbound and outbound resolvers
  enable_outbound_resolver = true
  enable_inbound_resolver  = true

  # Outbound resolver rules (forward specific domains to external DNS)
  resolver_rules = {
    # Corporate DNS forwarding
    "corporate-dns" = {
      domain_name = "corporate.company.com"
      name        = "corporate-dns-forward"
      target_ips  = ["10.0.1.10", "10.0.1.11"]  # Corporate DNS servers
    },
    
    # Partner DNS forwarding
    "partner-dns" = {
      domain_name = "partner.example.com"
      name        = "partner-dns-forward"
      target_ips  = ["203.0.113.10", "203.0.113.11"]  # Partner DNS servers
    },
    
    # Development DNS forwarding
    "dev-dns" = {
      domain_name = "dev.example.com"
      name        = "dev-dns-forward"
      target_ips  = ["8.8.8.8", "8.8.4.4"]  # Google DNS
    },
    
    # Staging DNS forwarding
    "staging-dns" = {
      domain_name = "staging.example.com"
      name        = "staging-dns-forward"
      target_ips  = ["1.1.1.1", "1.0.0.1"]  # Cloudflare DNS
    }
  }

  # Inbound resolver rules (for internal domains)
  inbound_resolver_rules = {
    # Internal domain resolution
    "internal-domain" = {
      domain_name = "internal.example.com"
      name        = "internal-domain-resolver"
    },
    
    # Private domain resolution
    "private-domain" = {
      domain_name = "private.example.com"
      name        = "private-domain-resolver"
    },
    
    # Database domain resolution
    "database-domain" = {
      domain_name = "database.example.com"
      name        = "database-domain-resolver"
    },
    
    # Monitoring domain resolution
    "monitoring-domain" = {
      domain_name = "monitoring.example.com"
      name        = "monitoring-domain-resolver"
    }
  }
}

# Example of what gets created:

# Outbound Resolver Rules:
# - corporate.company.com → 10.0.1.10, 10.0.1.11
# - partner.example.com → 203.0.113.10, 203.0.113.11
# - dev.example.com → 8.8.8.8, 8.8.4.4
# - staging.example.com → 1.1.1.1, 1.0.0.1
#
# Inbound Resolver Rules:
# - internal.example.com (recursive resolution)
# - private.example.com (recursive resolution)
# - database.example.com (recursive resolution)
# - monitoring.example.com (recursive resolution)
#
# Resolver Endpoints:
# - Outbound endpoint in private subnets
# - Inbound endpoint in private subnets
# - Security groups with proper DNS rules
#
# Benefits:
# - Centralized DNS configuration
# - Easy to modify without code changes
# - Environment-specific configurations
# - Clear separation of concerns 