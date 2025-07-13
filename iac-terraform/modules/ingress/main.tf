# NGINX Ingress Controller Module
# Deploys both external and internal NGINX Ingress Controllers to EKS cluster

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = var.cluster_token
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    token                  = var.cluster_token
  }
}

# Create namespace for ingress controllers
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = merge(var.tags, {
      name = "ingress-nginx"
    })
  }
}

# Data sources to get load balancer hostnames
data "kubernetes_service" "external_controller" {
  metadata {
    name      = "ingress-nginx-external-controller"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
  depends_on = [helm_release.ingress_nginx_external]
}

data "kubernetes_service" "internal_controller" {
  metadata {
    name      = "ingress-nginx-internal-controller"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
  depends_on = [helm_release.ingress_nginx_internal]
}

# External NGINX Ingress Controller (Internet-facing)
resource "helm_release" "ingress_nginx_external" {
  name       = "ingress-nginx-external"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_version
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = join(",", var.public_subnet_ids)
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = join(",", [for k, v in var.tags : "${k}=${v}"])
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
    value = "${var.environment}-external-nginx"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = var.external_controller_cpu_request
  }

  set {
    name  = "controller.resources.requests.memory"
    value = var.external_controller_memory_request
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = var.external_controller_cpu_limit
  }

  set {
    name  = "controller.resources.limits.memory"
    value = var.external_controller_memory_limit
  }

  set {
    name  = "controller.replicaCount"
    value = var.external_controller_replicas
  }

  set {
    name  = "controller.config.enable-real-ip"
    value = "true"
  }

  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
  }

  set {
    name  = "controller.config.proxy-real-ip-cidr"
    value = "0.0.0.0/0"
  }

  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }

  # Enable metrics for monitoring
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = var.enable_prometheus_monitoring
  }

  # Security settings
  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "true"
  }

  set {
    name  = "controller.admissionWebhooks.patch.enabled"
    value = "true"
  }

  # Pod security context
  set {
    name  = "controller.podSecurityContext.fsGroup"
    value = "101"
  }

  set {
    name  = "controller.containerSecurityContext.allowPrivilegeEscalation"
    value = "false"
  }

  set {
    name  = "controller.containerSecurityContext.capabilities.drop[0]"
    value = "ALL"
  }

  set {
    name  = "controller.containerSecurityContext.readOnlyRootFilesystem"
    value = "true"
  }

  set {
    name  = "controller.containerSecurityContext.runAsNonRoot"
    value = "true"
  }

  set {
    name  = "controller.containerSecurityContext.runAsUser"
    value = "101"
  }

  # Node selector for better resource utilization
  dynamic "set" {
    for_each = var.node_selector
    content {
      name  = "controller.nodeSelector.${set.key}"
      value = set.value
    }
  }

  # Tolerations for node placement
  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].key"
      value = set.value.key
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].operator"
      value = set.value.operator
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].value"
      value = set.value.value
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].effect"
      value = set.value.effect
    }
  }

  depends_on = [kubernetes_namespace.ingress_nginx]
}

# Internal NGINX Ingress Controller (Private)
resource "helm_release" "ingress_nginx_internal" {
  name       = "ingress-nginx-internal"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_version
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internal"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = join(",", var.private_subnet_ids)
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = join(",", [for k, v in var.tags : "${k}=${v}"])
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
    value = "${var.environment}-internal-nginx"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = var.internal_controller_cpu_request
  }

  set {
    name  = "controller.resources.requests.memory"
    value = var.internal_controller_memory_request
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = var.internal_controller_cpu_limit
  }

  set {
    name  = "controller.resources.limits.memory"
    value = var.internal_controller_memory_limit
  }

  set {
    name  = "controller.replicaCount"
    value = var.internal_controller_replicas
  }

  set {
    name  = "controller.config.enable-real-ip"
    value = "true"
  }

  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
  }

  set {
    name  = "controller.config.proxy-real-ip-cidr"
    value = "0.0.0.0/0"
  }

  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }

  # Enable metrics for monitoring
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = var.enable_prometheus_monitoring
  }

  # Security settings
  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "true"
  }

  set {
    name  = "controller.admissionWebhooks.patch.enabled"
    value = "true"
  }

  # Pod security context
  set {
    name  = "controller.podSecurityContext.fsGroup"
    value = "101"
  }

  set {
    name  = "controller.containerSecurityContext.allowPrivilegeEscalation"
    value = "false"
  }

  set {
    name  = "controller.containerSecurityContext.capabilities.drop[0]"
    value = "ALL"
  }

  set {
    name  = "controller.containerSecurityContext.readOnlyRootFilesystem"
    value = "true"
  }

  set {
    name  = "controller.containerSecurityContext.runAsNonRoot"
    value = "true"
  }

  set {
    name  = "controller.containerSecurityContext.runAsUser"
    value = "101"
  }

  # Node selector for better resource utilization
  dynamic "set" {
    for_each = var.node_selector
    content {
      name  = "controller.nodeSelector.${set.key}"
      value = set.value
    }
  }

  # Tolerations for node placement
  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].key"
      value = set.value.key
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].operator"
      value = set.value.operator
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].value"
      value = set.value.value
    }
  }

  dynamic "set" {
    for_each = var.tolerations
    content {
      name  = "controller.tolerations[${set.key}].effect"
      value = set.value.effect
    }
  }

  depends_on = [kubernetes_namespace.ingress_nginx]
}

# Create default backend service
resource "kubernetes_service" "default_backend" {
  metadata {
    name      = "default-backend"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.tags, {
      app = "default-backend"
    })
  }

  spec {
    port {
      port        = 80
      target_port = 8080
    }

    selector = {
      app = "default-backend"
    }
  }
}

# Create default backend deployment
resource "kubernetes_deployment" "default_backend" {
  metadata {
    name      = "default-backend"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.tags, {
      app = "default-backend"
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "default-backend"
      }
    }

    template {
      metadata {
        labels = merge(var.tags, {
          app = "default-backend"
        })
      }

      spec {
        container {
          name  = "default-backend"
          image = "k8s.gcr.io/defaultbackend-amd64:1.5"

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "10m"
              memory = "20Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "20Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
          }
        }
      }
    }
  }
} 