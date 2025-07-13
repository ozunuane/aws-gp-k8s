# Example: Multi-Domain Configuration
# This file shows how to configure multiple domains with SSL certificates

# Example ACM module configuration for multiple domains
module "acm_example" {
  source = "../modules/acm"

  environment = "dev"

  # Multiple domains configuration
  domains = {
    # Primary domain
    primary = {
      domain_name = "dev.example.com"
      subject_alternative_names = [
        "*.dev.example.com",
        "api.dev.example.com",
        "app.dev.example.com"
      ]
      validation_method        = "DNS"
      route53_zone_id          = "Z1234567890ABC"
      use_existing_certificate = false
    }

    # Secondary domain
    secondary = {
      domain_name = "dev.example2.com"
      subject_alternative_names = [
        "*.dev.example2.com",
        "api.dev.example2.com"
      ]
      validation_method        = "DNS"
      route53_zone_id          = "Z0987654321XYZ"
      use_existing_certificate = false
    }

    # Third domain (for different environment)
    staging = {
      domain_name = "staging.example.com"
      subject_alternative_names = [
        "*.staging.example.com",
        "api.staging.example.com"
      ]
      validation_method        = "DNS"
      route53_zone_id          = "Z555666777888"
      use_existing_certificate = false
    }

    # Domain with existing certificate
    existing = {
      domain_name               = "existing.example.com"
      subject_alternative_names = []
      validation_method         = "DNS"
      route53_zone_id           = "Z999888777666"
      use_existing_certificate  = true
    }
  }

  tags = {
    Environment = "dev"
    Project     = "multi-domain-example"
  }
}

# Example outputs
output "all_certificate_arns" {
  description = "All certificate ARNs"
  value       = module.acm_example.certificate_arns
}

output "primary_certificate_arn" {
  description = "Primary certificate ARN"
  value       = module.acm_example.primary_certificate_arn
}

output "certificate_statuses" {
  description = "Certificate statuses"
  value       = module.acm_example.certificate_statuses
} 