# Example domain configuration with wildcard subdomains
# This shows how to configure domains with both specific subdomains and wildcard subdomains

domains = {
  # Primary domain with wildcard subdomains
  primary = {
    domain_name = "example.com"
    subdomains = ["www", "api", "app", "dev", "staging"]
    wildcard_subdomains = ["api", "app"]  # Creates *.api.example.com and *.app.example.com
    route53_zone_id = null
    create_hosted_zone = true
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
  
  # Secondary domain with different wildcard configuration
  secondary = {
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
    cname_records = [
      {
        name = "www.dev.myapp.com"
        value = "dev.myapp.com"
        ttl = 300
      }
    ]
  }
  
  # Domain using existing Route53 zone
  existing_zone = {
    domain_name = "existing-domain.com"
    subdomains = ["www", "api"]
    wildcard_subdomains = ["api", "services"]  # Creates *.api.existing-domain.com and *.services.existing-domain.com
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

# Example of what certificates will be created:
# 
# For primary domain (example.com):
# - example.com (main domain)
# - www.example.com
# - api.example.com
# - app.example.com
# - dev.example.com
# - staging.example.com
# - *.api.example.com (wildcard - covers any subdomain under api.example.com)
# - *.app.example.com (wildcard - covers any subdomain under app.example.com)
#
# For secondary domain (myapp.com):
# - myapp.com (main domain)
# - www.myapp.com
# - api.myapp.com
# - admin.myapp.com
# - *.api.myapp.com (wildcard - covers any subdomain under api.myapp.com)
#
# For existing_zone domain (existing-domain.com):
# - existing-domain.com (main domain)
# - www.existing-domain.com
# - api.existing-domain.com
# - *.api.existing-domain.com (wildcard)
# - *.services.existing-domain.com (wildcard) 