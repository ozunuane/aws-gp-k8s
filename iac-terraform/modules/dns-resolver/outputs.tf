# DNS Resolver Module Outputs

output "outbound_resolver_endpoint_id" {
  description = "ID of the outbound resolver endpoint"
  value       = var.enable_outbound_resolver ? aws_route53_resolver_endpoint.outbound[0].id : null
}

output "outbound_resolver_endpoint_ips" {
  description = "IP addresses of the outbound resolver endpoint"
  value       = var.enable_outbound_resolver ? aws_route53_resolver_endpoint.outbound[0].ip_address : []
}

output "inbound_resolver_endpoint_id" {
  description = "ID of the inbound resolver endpoint"
  value       = var.enable_inbound_resolver ? aws_route53_resolver_endpoint.inbound[0].id : null
}

output "inbound_resolver_endpoint_ips" {
  description = "IP addresses of the inbound resolver endpoint"
  value       = var.enable_inbound_resolver ? aws_route53_resolver_endpoint.inbound[0].ip_address : []
}

output "resolver_security_group_id" {
  description = "ID of the security group for resolver endpoints"
  value       = (var.enable_outbound_resolver || var.enable_inbound_resolver) ? aws_security_group.resolver[0].id : null
}

output "outbound_resolver_rules" {
  description = "Map of outbound resolver rules"
  value = {
    for k, v in aws_route53_resolver_rule.outbound : k => {
      id          = v.id
      domain_name = v.domain_name
      name        = v.name
    }
  }
}

output "inbound_resolver_rules" {
  description = "Map of inbound resolver rules"
  value = {
    for k, v in aws_route53_resolver_rule.inbound : k => {
      id          = v.id
      domain_name = v.domain_name
      name        = v.name
    }
  }
}

output "resolver_endpoints_status" {
  description = "Status of resolver endpoints"
  value = {
    outbound_enabled = var.enable_outbound_resolver
    inbound_enabled  = var.enable_inbound_resolver
    outbound_id      = var.enable_outbound_resolver ? aws_route53_resolver_endpoint.outbound[0].id : null
    inbound_id       = var.enable_inbound_resolver ? aws_route53_resolver_endpoint.inbound[0].id : null
  }
} 