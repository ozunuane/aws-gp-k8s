# Example DNS Configuration with Public and Private Domains
# This shows how to configure domains with both public and private hosted zones

domains = {
  # Public domain (external load balancer, public hosted zone)
  public = {
    domain_name = "example.com"
    subdomains = ["www", "api", "app", "dev"]
    wildcard_subdomains = ["api", "app"]
    route53_zone_id = null
    create_hosted_zone = true
    hosted_zone_type = "public"
    vpc_id = null  # Not needed for public zones
    load_balancer_type = "external"
    a_records = [
      {
        name = "dev.example.com"
        type = "A"
        ttl = 300
      },
      {
        name = "api.dev.example.com"
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
  
  # Private domain (internal load balancer, private hosted zone)
  private = {
    domain_name = "internal.example.com"
    subdomains = ["api", "admin", "monitoring", "database"]
    wildcard_subdomains = ["api", "admin"]
    route53_zone_id = null
    create_hosted_zone = true
    hosted_zone_type = "private"
    vpc_id = null  # Will be set in main.tf
    load_balancer_type = "internal"
    a_records = [
      {
        name = "api.internal.example.com"
        type = "A"
        ttl = 300
      },
      {
        name = "admin.internal.example.com"
        type = "A"
        ttl = 300
      },
      {
        name = "database.internal.example.com"
        type = "A"
        ttl = 300
      }
    ]
    cname_records = [
      {
        name = "monitoring.internal.example.com"
        value = "admin.internal.example.com"
        ttl = 300
      }
    ]
  }
  
  # Another public domain
  secondary = {
    domain_name = "myapp.com"
    subdomains = ["www", "api", "staging"]
    wildcard_subdomains = ["api"]
    route53_zone_id = null
    create_hosted_zone = true
    hosted_zone_type = "public"
    vpc_id = null
    load_balancer_type = "external"
    a_records = [
      {
        name = "staging.myapp.com"
        type = "A"
        ttl = 300
      }
    ]
    cname_records = [
      {
        name = "www.staging.myapp.com"
        value = "staging.myapp.com"
        ttl = 300
      }
    ]
  }
}

# DNS Resolver Configuration
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
    },
    "private-domain" = {
      domain_name = "private.example.com"
      name        = "private-domain-resolver"
    }
  }
}

# Example of what gets created:

# Public Hosted Zones:
# - example.com (public)
# - myapp.com (public)
#
# Private Hosted Zones:
# - internal.example.com (private, associated with VPC)
#
# Load Balancers:
# - External ALB: a1b2c3d4e5f6g7h8.us-west-2.elb.amazonaws.com
# - Internal ALB: i9j0k1l2m3n4o5p6.us-west-2.elb.amazonaws.com
#
# DNS Records:
# Public A Records (point to external ALB):
# - dev.example.com → external ALB
# - api.dev.example.com → external ALB
# - staging.myapp.com → external ALB
#
# Private A Records (point to internal ALB):
# - api.internal.example.com → internal ALB
# - admin.internal.example.com → internal ALB
# - database.internal.example.com → internal ALB
#
# DNS Resolver Endpoints:
# - Outbound: Forwards corporate.example.com to 8.8.8.8/8.8.4.4
# - Inbound: Handles internal.example.com resolution within VPC
#
# SSL Certificates:
# - example.com, *.api.example.com, *.app.example.com
# - internal.example.com, *.api.internal.example.com, *.admin.internal.example.com
# - myapp.com, *.api.myapp.com 