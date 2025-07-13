# DNS Resolver Module Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the resolver endpoints will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for resolver endpoints"
  type        = list(string)
}

variable "enable_outbound_resolver" {
  description = "Enable outbound resolver endpoint"
  type        = bool
  default     = true
}

variable "enable_inbound_resolver" {
  description = "Enable inbound resolver endpoint"
  type        = bool
  default     = true
}

variable "resolver_rules" {
  description = "Map of outbound resolver rules to forward DNS queries"
  type = map(object({
    domain_name = string
    name        = string
    target_ips  = list(string)
  }))
  default = {}
}

variable "inbound_resolver_rules" {
  description = "Map of inbound resolver rules for recursive DNS queries"
  type = map(object({
    domain_name = string
    name        = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 