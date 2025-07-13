# Production Environment - Terraform Variables

# Global configuration for this environment
global_config = {
  project_name = "aws-gp-k8s"
  organization = "godspower"
  aws_region   = "us-west-2"

  common_tags = {
    Project      = "aws-gp-k8s"
    Organization = "godspower"
    ManagedBy    = "terraform"
  }

  # Production environment VPC configuration
  vpc_cidr_blocks = {
    prod = "10.2.0.0/16"
  }

  public_subnet_cidrs = {
    prod = [
      "10.2.1.0/24",
      "10.2.2.0/24",
      "10.2.3.0/24"
    ]
  }

  private_subnet_cidrs = {
    prod = [
      "10.2.11.0/24",
      "10.2.12.0/24",
      "10.2.13.0/24"
    ]
  }

  kubernetes_versions = {
    prod = "1.28"
  }

  node_instance_types = {
    prod = ["m5.large", "m5.xlarge"]
  }

  node_scaling_config = {
    prod = {
      min_size     = 3
      max_size     = 10
      desired_size = 5
    }
  }

  enable_karpenter = {
    prod = true
  }

  enable_nat_gateway = {
    prod = true
  }

  enable_vpc_endpoints = {
    prod = true
  }

  enable_middleware = {
    prod = {
      redis      = true
      kafka      = true
      rabbitmq   = true
      documentdb = true
    }
  }
}

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
  "repo:godspower/aws-gp-k8s:ref:refs/heads/main"
]

# Security settings for production
create_access_keys = false # No access keys for production (use IAM roles instead)
enforce_mfa        = true

# Domain and SSL Configuration
domains = {
  # Public domain (external load balancer)
  public = {
    domain_name         = "example.com"
    subdomains          = ["www", "api", "app"]
    wildcard_subdomains = ["api", "app"]
    route53_zone_id     = null # Auto-create hosted zone
    create_hosted_zone  = true
    hosted_zone_type    = "public"
    vpc_id              = null # Not needed for public zones
    load_balancer_type  = "external"
    a_records = [
      {
        name = "example.com"
        type = "A"
        ttl  = 300
      },
      {
        name = "api.example.com"
        type = "A"
        ttl  = 300
      }
    ]
    cname_records = [
      {
        name  = "www.example.com"
        value = "example.com"
        ttl   = 300
      },
      {
        name  = "app.example.com"
        value = "example.com"
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
    subdomains          = ["www", "api"]
    wildcard_subdomains = ["api"]
    route53_zone_id     = null # Auto-create hosted zone
    create_hosted_zone  = true
    hosted_zone_type    = "public"
    vpc_id              = null # Not needed for public zones
    load_balancer_type  = "external"
    a_records = [
      {
        name = "example2.com"
        type = "A"
        ttl  = 300
      }
    ]
    cname_records = [
      {
        name  = "www.example2.com"
        value = "example2.com"
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