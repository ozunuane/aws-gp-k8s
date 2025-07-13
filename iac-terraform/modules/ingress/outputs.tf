# NGINX Ingress Controller Module Outputs

output "ingress_controller_namespace" {
  description = "Namespace where NGINX Ingress Controllers are deployed"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

# External Controller Outputs
output "external_ingress_controller_service_name" {
  description = "Name of the external NGINX Ingress Controller service"
  value       = "ingress-nginx-external-controller"
}

output "external_ingress_controller_service_namespace" {
  description = "Namespace of the external NGINX Ingress Controller service"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "external_load_balancer_hostname" {
  description = "Hostname of the external load balancer"
  value       = data.kubernetes_service.external_controller.status[0].load_balancer[0].ingress[0].hostname
}

output "external_load_balancer_zone_id" {
  description = "Zone ID of the external load balancer for A record creation"
  value       = "Z35SXDOTRQ7X7K" # AWS Application Load Balancer zone ID
}

output "external_ingress_class" {
  description = "Ingress class name for external NGINX Ingress Controller"
  value       = "nginx-external"
}

output "external_metrics_endpoint" {
  description = "Metrics endpoint for external NGINX Ingress Controller"
  value       = "http://${helm_release.ingress_nginx_external.name}-controller-metrics.${kubernetes_namespace.ingress_nginx.metadata[0].name}.svc.cluster.local:10254/metrics"
}

output "external_health_check_endpoint" {
  description = "Health check endpoint for external NGINX Ingress Controller"
  value       = "http://${helm_release.ingress_nginx_external.name}-controller.${kubernetes_namespace.ingress_nginx_external.metadata[0].namespace}.svc.cluster.local:10254/healthz"
}

output "external_helm_release_name" {
  description = "Name of the Helm release for external NGINX Ingress Controller"
  value       = helm_release.ingress_nginx_external.name
}

output "external_helm_release_namespace" {
  description = "Namespace of the external Helm release"
  value       = helm_release.ingress_nginx_external.namespace
}

output "external_helm_release_version" {
  description = "Version of the external Helm chart deployed"
  value       = helm_release.ingress_nginx_external.version
}

output "external_helm_release_status" {
  description = "Status of the external Helm release"
  value       = helm_release.ingress_nginx_external.status
}

output "external_controller_replicas" {
  description = "Number of external controller replicas deployed"
  value       = var.external_controller_replicas
}

output "external_controller_resources" {
  description = "Resource configuration for the external controller"
  value = {
    cpu_request    = var.external_controller_cpu_request
    memory_request = var.external_controller_memory_request
    cpu_limit      = var.external_controller_cpu_limit
    memory_limit   = var.external_controller_memory_limit
  }
}

# Internal Controller Outputs
output "internal_ingress_controller_service_name" {
  description = "Name of the internal NGINX Ingress Controller service"
  value       = "ingress-nginx-internal-controller"
}

output "internal_ingress_controller_service_namespace" {
  description = "Namespace of the internal NGINX Ingress Controller service"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "internal_load_balancer_hostname" {
  description = "Hostname of the internal load balancer"
  value       = data.kubernetes_service.internal_controller.status[0].load_balancer[0].ingress[0].hostname
}

output "internal_load_balancer_zone_id" {
  description = "Zone ID of the internal load balancer for A record creation"
  value       = "Z35SXDOTRQ7X7K" # AWS Application Load Balancer zone ID
}

output "internal_ingress_class" {
  description = "Ingress class name for internal NGINX Ingress Controller"
  value       = "nginx-internal"
}

output "internal_metrics_endpoint" {
  description = "Metrics endpoint for internal NGINX Ingress Controller"
  value       = "http://${helm_release.ingress_nginx_internal.name}-controller-metrics.${kubernetes_namespace.ingress_nginx.metadata[0].name}.svc.cluster.local:10254/metrics"
}

output "internal_health_check_endpoint" {
  description = "Health check endpoint for internal NGINX Ingress Controller"
  value       = "http://${helm_release.ingress_nginx_internal.name}-controller.${kubernetes_namespace.ingress_nginx_internal.metadata[0].namespace}.svc.cluster.local:10254/healthz"
}

output "internal_helm_release_name" {
  description = "Name of the Helm release for internal NGINX Ingress Controller"
  value       = helm_release.ingress_nginx_internal.name
}

output "internal_helm_release_namespace" {
  description = "Namespace of the internal Helm release"
  value       = helm_release.ingress_nginx_internal.namespace
}

output "internal_helm_release_version" {
  description = "Version of the internal Helm chart deployed"
  value       = helm_release.ingress_nginx_internal.version
}

output "internal_helm_release_status" {
  description = "Status of the internal Helm release"
  value       = helm_release.ingress_nginx_internal.status
}

output "internal_controller_replicas" {
  description = "Number of internal controller replicas deployed"
  value       = var.internal_controller_replicas
}

output "internal_controller_resources" {
  description = "Resource configuration for the internal controller"
  value = {
    cpu_request    = var.internal_controller_cpu_request
    memory_request = var.internal_controller_memory_request
    cpu_limit      = var.internal_controller_cpu_limit
    memory_limit   = var.internal_controller_memory_limit
  }
}

# Shared Outputs
output "default_backend_service_name" {
  description = "Name of the default backend service"
  value       = kubernetes_service.default_backend.metadata[0].name
}

output "default_backend_service_namespace" {
  description = "Namespace of the default backend service"
  value       = kubernetes_service.default_backend.metadata[0].namespace
}

output "ssl_termination_enabled" {
  description = "Whether SSL termination is enabled"
  value       = var.enable_ssl_termination
}

output "access_logs_enabled" {
  description = "Whether access logs are enabled"
  value       = var.enable_access_logs
}

output "waf_enabled" {
  description = "Whether WAF is enabled"
  value       = var.enable_waf
}

output "metrics_enabled" {
  description = "Whether metrics are enabled"
  value       = var.enable_metrics
}

output "admission_webhook_enabled" {
  description = "Whether admission webhook is enabled"
  value       = var.enable_admission_webhook
}

output "default_backend_enabled" {
  description = "Whether default backend is enabled"
  value       = var.enable_default_backend
}

output "tags" {
  description = "Tags applied to the ingress controller resources"
  value       = var.tags
}

# Controller Status Summary
output "controllers_status" {
  description = "Status summary of both controllers"
  value = {
    external = {
      enabled       = var.enable_external_controller
      status        = helm_release.ingress_nginx_external.status
      replicas      = var.external_controller_replicas
      ingress_class = "nginx-external"
    }
    internal = {
      enabled       = var.enable_internal_controller
      status        = helm_release.ingress_nginx_internal.status
      replicas      = var.internal_controller_replicas
      ingress_class = "nginx-internal"
    }
  }
} 