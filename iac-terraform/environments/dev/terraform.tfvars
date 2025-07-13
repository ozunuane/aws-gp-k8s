# Development Environment - Terraform Variables

# Environment-specific overrides
enable_dedicated_karpenter = true

# User configurations
devops_users = {
  "devops1" = {
    name = "john.doe"
  }
}

developer_users = {
  "dev1" = {
    name = "jane.smith"
  }
  "dev2" = {
    name = "bob.johnson"
  }
}

qa_users = {
  "qa1" = {
    name = "alice.wilson"
  }
}

readonly_users = {
  "readonly1" = {
    name = "charlie.brown"
  }
}

# GitHub OIDC (update with your actual repository)
github_repository_subjects = [
  "repo:godspower/aws-gp-k8s:ref:refs/heads/main",
  "repo:godspower/aws-gp-k8s:ref:refs/heads/dev"
]

# Security settings for development
create_access_keys = true # Required for programmatic S3 access
enforce_mfa        = false

# Domain and SSL Configuration
domains = {
  # Public domain (external load balancer)
  public = {
    domain_name         = "example.com"
    subdomains          = ["www", "api", "app", "dev"]
    wildcard_subdomains = ["api", "app"]
    route53_zone_id     = null # Auto-create hosted zone
    create_hosted_zone  = true
    hosted_zone_type    = "public"
    vpc_id              = null # Not needed for public zones
    load_balancer_type  = "external"
    a_records = [
      {
        name = "dev.example.com"
        type = "A"
        ttl  = 300
      },
      {
        name = "api.dev.example.com"
        type = "A"
        ttl  = 300
      }
    ]
    cname_records = [
      {
        name  = "www.dev.example.com"
        value = "dev.example.com"
        ttl   = 300
      },
      {
        name  = "app.dev.example.com"
        value = "dev.example.com"
        ttl   = 300
      }
    ]
  }

  # Private domain (internal load balancer)
  private = {
    domain_name         = "internal.example.com"
    subdomains          = ["api", "admin", "monitoring"]
    wildcard_subdomains = ["api"]
    route53_zone_id     = null # Auto-create hosted zone
    create_hosted_zone  = true
    hosted_zone_type    = "private"
    vpc_id              = null # Will be set in main.tf
    load_balancer_type  = "internal"
    a_records = [
      {
        name = "api.internal.example.com"
        type = "A"
        ttl  = 300
      },
      {
        name = "admin.internal.example.com"
        type = "A"
        ttl  = 300
      }
    ]
    cname_records = [
      {
        name  = "monitoring.internal.example.com"
        value = "admin.internal.example.com"
        ttl   = 300
      }
    ]
  }

  # Secondary public domain
  secondary = {
    domain_name         = "example2.com"
    subdomains          = ["www", "api", "dev"]
    wildcard_subdomains = ["api"]
    route53_zone_id     = null # Auto-create hosted zone
    create_hosted_zone  = true
    hosted_zone_type    = "public"
    vpc_id              = null # Not needed for public zones
    load_balancer_type  = "external"
    a_records = [
      {
        name = "dev.example2.com"
        type = "A"
        ttl  = 300
      }
    ]
    cname_records = [
      {
        name  = "www.dev.example2.com"
        value = "dev.example2.com"
        ttl   = 300
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