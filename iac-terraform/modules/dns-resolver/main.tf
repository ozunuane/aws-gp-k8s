# DNS Resolver Module
# Sets up Route53 Resolver for VPC with inbound and outbound endpoints

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Route53 Resolver Outbound Endpoint
resource "aws_route53_resolver_endpoint" "outbound" {
  count = var.enable_outbound_resolver ? 1 : 0

  name      = "${var.environment}-outbound-resolver"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.resolver[0].id]
  ip_address {
    subnet_id = var.private_subnet_ids[0]
  }

  ip_address {
    subnet_id = var.private_subnet_ids[1]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-outbound-resolver"
  })
}

# Route53 Resolver Inbound Endpoint
resource "aws_route53_resolver_endpoint" "inbound" {
  count = var.enable_inbound_resolver ? 1 : 0

  name      = "${var.environment}-inbound-resolver"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.resolver[0].id]
  ip_address {
    subnet_id = var.private_subnet_ids[0]
  }

  ip_address {
    subnet_id = var.private_subnet_ids[1]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-inbound-resolver"
  })
}

# Security Group for Resolver Endpoints
resource "aws_security_group" "resolver" {
  count = var.enable_outbound_resolver || var.enable_inbound_resolver ? 1 : 0

  name_prefix = "${var.environment}-resolver-"
  vpc_id      = var.vpc_id

  # Outbound resolver rules
  dynamic "egress" {
    for_each = var.enable_outbound_resolver ? [1] : []
    content {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.enable_outbound_resolver ? [1] : []
    content {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Inbound resolver rules
  dynamic "ingress" {
    for_each = var.enable_inbound_resolver ? [1] : []
    content {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  dynamic "ingress" {
    for_each = var.enable_inbound_resolver ? [1] : []
    content {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-resolver-sg"
  })
}

# Route53 Resolver Rules for Outbound
resource "aws_route53_resolver_rule" "outbound" {
  for_each = var.enable_outbound_resolver ? var.resolver_rules : {}

  domain_name          = each.value.domain_name
  name                 = each.value.name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound[0].id

  dynamic "target_ip" {
    for_each = each.value.target_ips
    content {
      ip = target_ip.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.key}-rule"
  })
}

# Route53 Resolver Rules for Inbound
resource "aws_route53_resolver_rule" "inbound" {
  for_each = var.enable_inbound_resolver ? var.inbound_resolver_rules : {}

  domain_name = each.value.domain_name
  name        = each.value.name
  rule_type   = "RECURSIVE"

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.key}-inbound-rule"
  })
}

# Associate resolver rules with VPC
resource "aws_route53_resolver_rule_association" "outbound" {
  for_each = var.enable_outbound_resolver ? var.resolver_rules : {}

  resolver_rule_id = aws_route53_resolver_rule.outbound[each.key].id
  vpc_id           = var.vpc_id
}

resource "aws_route53_resolver_rule_association" "inbound" {
  for_each = var.enable_inbound_resolver ? var.inbound_resolver_rules : {}

  resolver_rule_id = aws_route53_resolver_rule.inbound[each.key].id
  vpc_id           = var.vpc_id
} 