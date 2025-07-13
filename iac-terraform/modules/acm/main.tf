# AWS Certificate Manager (ACM) Module
# Manages SSL certificates for multiple domains with automatic Route53 hosted zone creation

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create Route53 hosted zones for each domain
resource "aws_route53_zone" "domains" {
  for_each = {
    for k, v in var.domains : k => v
    if v.create_hosted_zone == true
  }

  name = each.value.domain_name

  # Configure as private hosted zone if specified
  dynamic "vpc" {
    for_each = each.value.hosted_zone_type == "private" ? [1] : []
    content {
      vpc_id = each.value.vpc_id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.key}-zone"
    Domain = each.value.domain_name
    Type = each.value.hosted_zone_type
  })
}

# Create certificates for multiple domains
resource "aws_acm_certificate" "domains" {
  for_each = var.domains

  domain_name = each.value.domain_name
  subject_alternative_names = concat(
    [for subdomain in each.value.subdomains : "${subdomain}.${each.value.domain_name}"],
    [for wildcard_subdomain in each.value.wildcard_subdomains : "*.${wildcard_subdomain}.${each.value.domain_name}"]
  )
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.key}-cert"
    Domain = each.value.domain_name
  })
}

# Certificate validation records for each domain
resource "aws_route53_record" "validation" {
  for_each = {
    for pair in setproduct(keys(var.domains), [for dvo in aws_acm_certificate.domains[pair[0]].domain_validation_options : dvo.domain_name]) : "${pair[0]}-${pair[1]}" => {
      domain_key = pair[0]
      domain_name = pair[1]
      dvo = [for dvo in aws_acm_certificate.domains[pair[0]].domain_validation_options : dvo if dvo.domain_name == pair[1]][0]
    }
    if var.domains[pair[0]].route53_zone_id != null || var.domains[pair[0]].create_hosted_zone == true
  }

  allow_overwrite = true
  name            = each.value.dvo.resource_record_name
  records         = [each.value.dvo.resource_record_value]
  ttl             = 60
  type            = each.value.dvo.resource_record_type
  
  # Use existing zone ID or newly created zone ID
  zone_id = var.domains[each.value.domain_key].route53_zone_id != null ? var.domains[each.value.domain_key].route53_zone_id : aws_route53_zone.domains[each.value.domain_key].zone_id

  depends_on = [aws_acm_certificate.domains]
}

# Certificate validation for each domain
resource "aws_acm_certificate_validation" "domains" {
  for_each = {
    for k, v in var.domains : k => v
    if v.route53_zone_id != null || v.create_hosted_zone == true
  }

  certificate_arn = aws_acm_certificate.domains[each.key].arn
  validation_record_fqdns = [
    for record in aws_route53_record.validation : record.fqdn
    if split("-", record.id)[0] == each.key
  ]

  timeouts {
    create = "5m"
  }
}

# A Records for load balancer endpoints
resource "aws_route53_record" "a_records" {
  for_each = {
    for pair in setproduct(keys(var.domains), var.domains[pair[0]].a_records) : "${pair[0]}-${pair[1].name}" => {
      domain_key = pair[0]
      a_record_config = pair[1]
    }
    if var.domains[pair[0]].route53_zone_id != null || var.domains[pair[0]].create_hosted_zone == true
  }

  zone_id = var.domains[each.value.domain_key].route53_zone_id != null ? var.domains[each.value.domain_key].route53_zone_id : aws_route53_zone.domains[each.value.domain_key].zone_id
  name    = each.value.a_record_config.name
  type    = each.value.a_record_config.type
  ttl     = each.value.a_record_config.ttl

  alias {
    name = var.domains[each.value.domain_key].load_balancer_type == "internal" && var.internal_load_balancer_dns_name != null ? var.internal_load_balancer_dns_name : var.load_balancer_dns_name
    zone_id = var.domains[each.value.domain_key].load_balancer_type == "internal" && var.internal_load_balancer_zone_id != null ? var.internal_load_balancer_zone_id : var.load_balancer_zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_acm_certificate_validation.domains]
}

# CNAME Records for subdomains
resource "aws_route53_record" "cname_records" {
  for_each = {
    for pair in setproduct(keys(var.domains), var.domains[pair[0]].cname_records) : "${pair[0]}-${pair[1].name}" => {
      domain_key = pair[0]
      cname_config = pair[1]
    }
    if var.domains[pair[0]].route53_zone_id != null || var.domains[pair[0]].create_hosted_zone == true
  }

  zone_id = var.domains[each.value.domain_key].route53_zone_id != null ? var.domains[each.value.domain_key].route53_zone_id : aws_route53_zone.domains[each.value.domain_key].zone_id
  name    = each.value.cname_config.name
  type    = "CNAME"
  ttl     = each.value.cname_config.ttl
  records = [each.value.cname_config.value]

  depends_on = [aws_acm_certificate_validation.domains]
}

# Output the certificate ARNs
locals {
  certificate_arns = {
    for k, v in var.domains : k => aws_acm_certificate.domains[k].arn
  }
  
  # Output hosted zone information
  hosted_zone_ids = {
    for k, v in var.domains : k => v.route53_zone_id != null ? v.route53_zone_id : (v.create_hosted_zone ? aws_route53_zone.domains[k].zone_id : null)
  }
  
  hosted_zone_nameservers = {
    for k, v in aws_route53_zone.domains : k => v.name_servers
  }
} 