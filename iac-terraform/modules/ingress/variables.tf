# NGINX Ingress Controller Module Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "cluster_token" {
  description = "EKS cluster authentication token"
  type        = string
  sensitive   = true
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for external load balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for internal load balancer"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "ingress_nginx_version" {
  description = "NGINX Ingress Controller Helm chart version"
  type        = string
  default     = "4.7.1"
}

# External Controller Configuration
variable "external_controller_replicas" {
  description = "Number of external NGINX controller replicas"
  type        = number
  default     = 2
}

variable "external_controller_cpu_request" {
  description = "CPU request for external NGINX controller"
  type        = string
  default     = "100m"
}

variable "external_controller_memory_request" {
  description = "Memory request for external NGINX controller"
  type        = string
  default     = "128Mi"
}

variable "external_controller_cpu_limit" {
  description = "CPU limit for external NGINX controller"
  type        = string
  default     = "200m"
}

variable "external_controller_memory_limit" {
  description = "Memory limit for external NGINX controller"
  type        = string
  default     = "256Mi"
}

# Internal Controller Configuration
variable "internal_controller_replicas" {
  description = "Number of internal NGINX controller replicas"
  type        = number
  default     = 1
}

variable "internal_controller_cpu_request" {
  description = "CPU request for internal NGINX controller"
  type        = string
  default     = "50m"
}

variable "internal_controller_memory_request" {
  description = "Memory request for internal NGINX controller"
  type        = string
  default     = "64Mi"
}

variable "internal_controller_cpu_limit" {
  description = "CPU limit for internal NGINX controller"
  type        = string
  default     = "100m"
}

variable "internal_controller_memory_limit" {
  description = "Memory limit for internal NGINX controller"
  type        = string
  default     = "128Mi"
}

variable "enable_prometheus_monitoring" {
  description = "Enable Prometheus monitoring for NGINX controller"
  type        = bool
  default     = false
}

variable "node_selector" {
  description = "Node selector for NGINX controller pods"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for NGINX controller pods"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "enable_ssl_termination" {
  description = "Enable SSL termination at the load balancer"
  type        = bool
  default     = true
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS termination"
  type        = string
  default     = null
}

variable "enable_access_logs" {
  description = "Enable access logs for NGINX controller"
  type        = bool
  default     = true
}

variable "access_logs_s3_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

variable "access_logs_s3_prefix" {
  description = "S3 prefix for access logs"
  type        = string
  default     = "nginx-logs"
}

variable "enable_waf" {
  description = "Enable AWS WAF for the load balancer"
  type        = bool
  default     = false
}

variable "waf_web_acl_arn" {
  description = "ARN of WAF Web ACL"
  type        = string
  default     = null
}

variable "enable_shield" {
  description = "Enable AWS Shield Advanced for DDoS protection"
  type        = bool
  default     = false
}

variable "controller_config" {
  description = "Additional NGINX controller configuration"
  type        = map(string)
  default     = {}
}

variable "default_ssl_certificate" {
  description = "Default SSL certificate for the controller"
  type        = string
  default     = null
}

variable "enable_default_backend" {
  description = "Enable default backend for 404 responses"
  type        = bool
  default     = true
}

variable "default_backend_image" {
  description = "Default backend container image"
  type        = string
  default     = "k8s.gcr.io/defaultbackend-amd64:1.5"
}

variable "enable_admission_webhook" {
  description = "Enable admission webhook for ingress validation"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable metrics endpoint for monitoring"
  type        = bool
  default     = true
}

variable "metrics_port" {
  description = "Port for metrics endpoint"
  type        = number
  default     = 10254
}

variable "enable_health_check" {
  description = "Enable health check endpoint"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/healthz"
}

variable "health_check_port" {
  description = "Health check port"
  type        = number
  default     = 10254
}

# Feature flags for external vs internal controllers
variable "enable_external_controller" {
  description = "Enable external (internet-facing) NGINX controller"
  type        = bool
  default     = true
}

variable "enable_internal_controller" {
  description = "Enable internal (private) NGINX controller"
  type        = bool
  default     = true
}

# External controller specific features
variable "external_enable_ssl_termination" {
  description = "Enable SSL termination for external controller"
  type        = bool
  default     = true
}

variable "external_enable_waf" {
  description = "Enable WAF for external controller"
  type        = bool
  default     = false
}

variable "external_enable_shield" {
  description = "Enable Shield for external controller"
  type        = bool
  default     = false
}

# Internal controller specific features
variable "internal_enable_ssl_termination" {
  description = "Enable SSL termination for internal controller"
  type        = bool
  default     = false
}

variable "internal_enable_waf" {
  description = "Enable WAF for internal controller"
  type        = bool
  default     = false
}

variable "internal_enable_shield" {
  description = "Enable Shield for internal controller"
  type        = bool
  default     = false
} 