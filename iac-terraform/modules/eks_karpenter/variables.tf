# EKS Karpenter Module - Variables

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_arn" {
  description = "EKS cluster ARN"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  type        = string
}

variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "v0.31.0"
}

variable "critical_instance_types" {
  description = "List of instance types for critical workloads"
  type        = list(string)
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge", "c5.large", "c5.xlarge", "c5.2xlarge"]
}

variable "non_critical_instance_types" {
  description = "List of instance types for non-critical workloads"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.xlarge", "m5.large", "m5.xlarge", "c5.large", "c5.xlarge", "r5.large", "r5.xlarge"]
}

variable "critical_cpu_limit" {
  description = "CPU limit for critical workloads provisioner"
  type        = number
  default     = 1000
}

variable "non_critical_cpu_limit" {
  description = "CPU limit for non-critical workloads provisioner"
  type        = number
  default     = 2000
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
} 