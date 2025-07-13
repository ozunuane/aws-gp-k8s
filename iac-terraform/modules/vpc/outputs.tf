# VPC Module - Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}

# VPC Endpoints Outputs
output "vpc_endpoints_enabled" {
  description = "Whether VPC endpoints are enabled"
  value       = var.enable_vpc_endpoints
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC Gateway Endpoint"
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "s3_endpoint_dns_entries" {
  description = "DNS entries for the S3 VPC Gateway Endpoint"
  value       = try(aws_vpc_endpoint.s3[0].dns_entry, null)
}

output "ec2_endpoint_id" {
  description = "ID of the EC2 VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.ec2[0].id, null)
}

output "ec2_endpoint_dns_entries" {
  description = "DNS entries for the EC2 VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.ec2[0].dns_entry, null)
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.ecr_api[0].id, null)
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR DKR VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.ecr_dkr[0].id, null)
}

output "eks_endpoint_id" {
  description = "ID of the EKS VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.eks[0].id, null)
}

output "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.logs[0].id, null)
}

output "secretsmanager_endpoint_id" {
  description = "ID of the Secrets Manager VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.secretsmanager[0].id, null)
}

output "ssm_endpoint_id" {
  description = "ID of the SSM VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.ssm[0].id, null)
}

output "ssm_messages_endpoint_id" {
  description = "ID of the SSM Messages VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.ssm_messages[0].id, null)
}

output "ec2_messages_endpoint_id" {
  description = "ID of the EC2 Messages VPC Interface Endpoint"
  value       = try(aws_vpc_endpoint.ec2_messages[0].id, null)
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the security group for VPC endpoints"
  value       = try(aws_security_group.vpc_endpoints[0].id, null)
}

# All VPC endpoints summary
output "vpc_endpoints" {
  description = "Map of all VPC endpoints created"
  value = {
    s3 = try({
      id           = aws_vpc_endpoint.s3[0].id
      type         = "Gateway"
      service_name = aws_vpc_endpoint.s3[0].service_name
    }, null)
    ec2 = try({
      id           = aws_vpc_endpoint.ec2[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.ec2[0].service_name
    }, null)
    ecr_api = try({
      id           = aws_vpc_endpoint.ecr_api[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.ecr_api[0].service_name
    }, null)
    ecr_dkr = try({
      id           = aws_vpc_endpoint.ecr_dkr[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.ecr_dkr[0].service_name
    }, null)
    eks = try({
      id           = aws_vpc_endpoint.eks[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.eks[0].service_name
    }, null)
    logs = try({
      id           = aws_vpc_endpoint.logs[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.logs[0].service_name
    }, null)
    secretsmanager = try({
      id           = aws_vpc_endpoint.secretsmanager[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.secretsmanager[0].service_name
    }, null)
    ssm = try({
      id           = aws_vpc_endpoint.ssm[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.ssm[0].service_name
    }, null)
    ssm_messages = try({
      id           = aws_vpc_endpoint.ssm_messages[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.ssm_messages[0].service_name
    }, null)
    ec2_messages = try({
      id           = aws_vpc_endpoint.ec2_messages[0].id
      type         = "Interface"
      service_name = aws_vpc_endpoint.ec2_messages[0].service_name
    }, null)
  }
} 