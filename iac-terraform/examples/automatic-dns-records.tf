# Example: Automatic DNS Record Creation
# This file shows how to configure automatic A and CNAME record creation

# Example ACM module with automatic DNS records
module "acm_with_dns" {
  source = "../modules/acm"

  environment = "dev"
  
  # Multiple domains with automatic DNS records
  domains = {
    # Primary domain with A record and CNAME
    primary = {
      domain_name = "dev.example.com"
      subject_alternative_names = [
        "*.dev.example.com",
        "api.dev.example.com"
      ]
      validation_method = "DNS"
      route53_zone_id   = null  # Auto-create hosted zone
      use_existing_certificate = false
      create_hosted_zone = true
      create_a_record = true  # Creates A record pointing to load balancer
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
    
    # Secondary domain with A record only
    secondary = {
      domain_name = "dev.example2.com"
      subject_alternative_names = [
        "*.dev.example2.com"
      ]
      validation_method = "DNS"
      route53_zone_id   = null  # Auto-create hosted zone
      use_existing_certificate = false
      create_hosted_zone = true
      create_a_record = true  # Creates A record pointing to load balancer
      cname_records = []  # No CNAME records
    }
    
    # Domain with existing hosted zone
    existing = {
      domain_name = "dev.example3.com"
      subject_alternative_names = []
      validation_method = "DNS"
      route53_zone_id   = "Z1234567890ABC"  # Existing hosted zone
      use_existing_certificate = false
      create_hosted_zone = false
      create_a_record = true  # Still creates A record
      cname_records = [
        {
          name  = "www.dev.example3.com"
          value = "dev.example3.com"
          ttl   = 300
        }
      ]
    }
    
    # Domain without A record (certificate only)
    cert_only = {
      domain_name = "api.example.com"
      subject_alternative_names = []
      validation_method = "DNS"
      route53_zone_id   = null
      use_existing_certificate = false
      create_hosted_zone = true
      create_a_record = false  # No A record created
      cname_records = []
    }
  }

  # Load balancer configuration (required for A records)
  load_balancer_dns_name = "dualstack.a1b2c3d4e5f6.us-west-2.elb.amazonaws.com"
  load_balancer_zone_id  = "Z35SXDOTRQ7X7K"  # AWS ALB zone ID

  tags = {
    Environment = "dev"
    Project     = "automatic-dns-example"
  }
}

# Example outputs
output "all_certificate_arns" {
  description = "All certificate ARNs"
  value       = module.acm_with_dns.certificate_arns
}

output "hosted_zone_nameservers" {
  description = "Nameservers for auto-created hosted zones"
  value       = module.acm_with_dns.hosted_zone_nameservers
}

output "a_records_created" {
  description = "A records that were created"
  value       = module.acm_with_dns.a_record_fqdns
}

output "cname_records_created" {
  description = "CNAME records that were created"
  value       = module.acm_with_dns.cname_record_fqdns
} 