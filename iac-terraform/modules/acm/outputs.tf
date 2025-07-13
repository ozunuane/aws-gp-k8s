# ACM Module Outputs

output "certificate_arns" {
  description = "Map of domain names to certificate ARNs"
  value       = local.certificate_arns
}

output "certificate_domain_names" {
  description = "Map of domain keys to domain names"
  value = {
    for k, v in var.domains : k => v.domain_name
  }
}

output "certificate_statuses" {
  description = "Map of domain names to certificate statuses"
  value = {
    for k, v in var.domains : k => aws_acm_certificate.domains[k].status
  }
}

output "validation_methods" {
  description = "Map of domain names to validation methods"
  value = {
    for k, v in var.domains : k => v.validation_method
  }
}

output "primary_certificate_arn" {
  description = "ARN of the primary certificate (first domain in the map)"
  value       = values(local.certificate_arns)[0]
}

output "hosted_zone_ids" {
  description = "Map of domain keys to hosted zone IDs"
  value       = local.hosted_zone_ids
}

output "hosted_zone_nameservers" {
  description = "Map of domain keys to nameservers (for domains with auto-created hosted zones)"
  value       = local.hosted_zone_nameservers
}

output "a_record_fqdns" {
  description = "Map of domain keys to A record FQDNs"
  value = {
    for k, v in aws_route53_record.a_records : k => v.fqdn
  }
}

output "cname_record_fqdns" {
  description = "Map of CNAME record keys to FQDNs"
  value = {
    for k, v in aws_route53_record.cname_records : k => v.fqdn
  }
} 