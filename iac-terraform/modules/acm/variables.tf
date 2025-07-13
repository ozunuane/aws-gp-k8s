# ACM Module Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domains" {
  description = "Map of domains and their configurations"
  type = map(object({
    domain_name = string
    subdomains = list(string)
    wildcard_subdomains = list(string)
    route53_zone_id = string
    create_hosted_zone = bool
    hosted_zone_type = string  # "public" or "private"
    vpc_id = string  # Required for private hosted zones
    load_balancer_type = string  # "external" or "internal"
    a_records = list(object({
      name = string
      type = string
      ttl = number
    }))
    cname_records = list(object({
      name = string
      value = string
      ttl = number
    }))
  }))
}

variable "load_balancer_dns_name" {
  description = "DNS name of the load balancer for A record creation"
  type        = string
}

variable "load_balancer_zone_id" {
  description = "Zone ID of the load balancer for A record creation"
  type        = string
}

variable "internal_load_balancer_dns_name" {
  description = "DNS name of the internal load balancer for A record creation"
  type        = string
  default     = null
}

variable "internal_load_balancer_zone_id" {
  description = "Zone ID of the internal load balancer for A record creation"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 