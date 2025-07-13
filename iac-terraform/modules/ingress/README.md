# NGINX Ingress Controller Module

This module deploys the NGINX Ingress Controller to an EKS cluster using Helm. It provides a production-ready ingress controller with AWS integration, security features, and monitoring capabilities.

## 🚀 Features

- **AWS Integration**: Automatic AWS Load Balancer creation with proper annotations
- **Security**: Pod security contexts, admission webhooks, and SSL termination
- **Monitoring**: Built-in metrics endpoint and Prometheus integration
- **Scalability**: Configurable replicas and resource limits
- **Cost Optimization**: Environment-specific configurations for dev/staging/prod
- **High Availability**: Multi-AZ deployment with proper health checks

## 📋 Prerequisites

- EKS cluster with proper IAM roles
- Helm provider configured
- Kubernetes provider configured
- Public subnets for load balancer placement

## 🔧 Usage

### Basic Usage

```hcl
module "ingress" {
  source = "../../modules/ingress"

  environment = "dev"

  # EKS cluster configuration
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  cluster_token          = module.eks.cluster_token

  # Network configuration
  public_subnet_ids = module.vpc.public_subnet_ids

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

### Advanced Usage with SSL and WAF

```hcl
module "ingress" {
  source = "../../modules/ingress"

  environment = "prod"

  # EKS cluster configuration
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  cluster_token          = module.eks.cluster_token

  # Network configuration
  public_subnet_ids = module.vpc.public_subnet_ids

  # Controller configuration
  controller_replicas = 3
  controller_cpu_request = "200m"
  controller_memory_request = "256Mi"
  controller_cpu_limit = "500m"
  controller_memory_limit = "512Mi"

  # Security features
  enable_ssl_termination = true
  ssl_certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/xxxxx"
  enable_waf = true
  waf_web_acl_arn = "arn:aws:wafv2:us-west-2:123456789012:regional/webacl/xxxxx"
  enable_shield = true

  # Monitoring
  enable_prometheus_monitoring = true
  enable_access_logs = true
  access_logs_s3_bucket = "my-logs-bucket"

  tags = {
    Environment = "prod"
    Project     = "my-project"
  }
}
```

## 📊 Configuration by Environment

### Development Environment

```hcl
module "ingress" {
  source = "../../modules/ingress"

  environment = "dev"

  # EKS cluster configuration
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  cluster_token          = module.eks.cluster_token

  # Network configuration
  public_subnet_ids = module.vpc.public_subnet_ids

  # Cost-optimized configuration
  controller_replicas = 1
  controller_cpu_request = "50m"
  controller_memory_request = "64Mi"
  controller_cpu_limit = "100m"
  controller_memory_limit = "128Mi"

  # Disable expensive features
  enable_ssl_termination = false
  enable_waf = false
  enable_shield = false
  enable_prometheus_monitoring = false

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

### Production Environment

```hcl
module "ingress" {
  source = "../../modules/ingress"

  environment = "prod"

  # EKS cluster configuration
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  cluster_token          = module.eks.cluster_token

  # Network configuration
  public_subnet_ids = module.vpc.public_subnet_ids

  # Production configuration
  controller_replicas = 3
  controller_cpu_request = "200m"
  controller_memory_request = "256Mi"
  controller_cpu_limit = "500m"
  controller_memory_limit = "512Mi"

  # Security features
  enable_ssl_termination = true
  ssl_certificate_arn = var.ssl_certificate_arn
  enable_waf = true
  waf_web_acl_arn = var.waf_web_acl_arn
  enable_shield = true

  # Monitoring
  enable_prometheus_monitoring = true
  enable_access_logs = true
  access_logs_s3_bucket = var.logs_bucket

  tags = {
    Environment = "prod"
    Project     = "my-project"
  }
}
```

## 🔍 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| cluster_endpoint | EKS cluster endpoint | `string` | n/a | yes |
| cluster_ca_certificate | EKS cluster CA certificate | `string` | n/a | yes |
| cluster_token | EKS cluster authentication token | `string` | n/a | yes |
| public_subnet_ids | List of public subnet IDs for load balancer | `list(string)` | n/a | yes |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |
| ingress_nginx_version | NGINX Ingress Controller Helm chart version | `string` | `"4.7.1"` | no |
| controller_replicas | Number of NGINX controller replicas | `number` | `2` | no |
| controller_cpu_request | CPU request for NGINX controller | `string` | `"100m"` | no |
| controller_memory_request | Memory request for NGINX controller | `string` | `"128Mi"` | no |
| controller_cpu_limit | CPU limit for NGINX controller | `string` | `"200m"` | no |
| controller_memory_limit | Memory limit for NGINX controller | `string` | `"256Mi"` | no |
| enable_prometheus_monitoring | Enable Prometheus monitoring | `bool` | `false` | no |
| enable_ssl_termination | Enable SSL termination | `bool` | `true` | no |
| ssl_certificate_arn | ARN of SSL certificate | `string` | `null` | no |
| enable_waf | Enable AWS WAF | `bool` | `false` | no |
| waf_web_acl_arn | ARN of WAF Web ACL | `string` | `null` | no |
| enable_shield | Enable AWS Shield Advanced | `bool` | `false` | no |
| enable_access_logs | Enable access logs | `bool` | `true` | no |
| access_logs_s3_bucket | S3 bucket for access logs | `string` | `null` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| ingress_controller_namespace | Namespace where NGINX Ingress Controller is deployed |
| ingress_controller_service_name | Name of the NGINX Ingress Controller service |
| ingress_class | Ingress class name for NGINX Ingress Controller |
| load_balancer_hostname | Hostname of the load balancer |
| metrics_endpoint | Metrics endpoint for monitoring |
| health_check_endpoint | Health check endpoint |
| default_backend_service_name | Name of the default backend service |
| ingress_controller_status | Status of the deployment |

## 🛠️ Using the Ingress Controller

### Creating Ingress Resources

After deploying the module, you can create ingress resources for your applications:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

### SSL/TLS Configuration

For HTTPS traffic, configure SSL certificates:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-https-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - app.example.com
    secretName: app-tls-secret
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

### Rate Limiting

Configure rate limiting for API endpoints:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-rate-limited-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

## 🔒 Security Features

### Pod Security Context

The module configures secure pod security contexts:

- **Non-root user**: Controller runs as user 101
- **Read-only filesystem**: Prevents file system modifications
- **Dropped capabilities**: Removes unnecessary Linux capabilities
- **No privilege escalation**: Prevents privilege escalation

### Admission Webhooks

Admission webhooks are enabled by default to validate ingress resources and prevent misconfigurations.

### SSL/TLS Termination

SSL termination can be enabled at the load balancer level with proper certificate management.

## 📈 Monitoring

### Metrics Endpoint

The controller exposes metrics on port 10254:

```bash
# Get metrics
curl http://ingress-nginx-controller.ingress-nginx.svc.cluster.local:10254/metrics
```

### Prometheus Integration

Enable Prometheus monitoring for detailed metrics collection:

```hcl
enable_prometheus_monitoring = true
```

### Health Checks

Health check endpoint is available at:

```bash
# Health check
curl http://ingress-nginx-controller.ingress-nginx.svc.cluster.local:10254/healthz
```

## 💰 Cost Optimization

### Development Environment

- **Single replica**: Reduces resource usage
- **Smaller resource limits**: Minimizes costs
- **Disabled expensive features**: No WAF, Shield, or SSL termination

### Production Environment

- **Multiple replicas**: Ensures high availability
- **Larger resource limits**: Handles production load
- **Security features**: WAF, Shield, SSL termination enabled

## 🚨 Troubleshooting

### Common Issues

1. **Load Balancer not created**: Check public subnet configuration
2. **Ingress not working**: Verify ingress class annotation
3. **SSL issues**: Ensure certificate ARN is correct
4. **High resource usage**: Adjust CPU/memory limits

### Debugging Commands

```bash
# Check controller status
kubectl get pods -n ingress-nginx

# Check service
kubectl get svc -n ingress-nginx

# Check ingress resources
kubectl get ingress --all-namespaces

# Check controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Check metrics
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller-metrics 10254:10254
curl localhost:10254/metrics
```

## 📚 Examples

See the `examples/` directory for sample ingress configurations:

- Basic ingress setup
- HTTPS configuration
- Rate limiting
- Load balancing
- CORS configuration

## 🔄 Updates and Maintenance

### Updating the Controller

To update the NGINX Ingress Controller version:

```hcl
ingress_nginx_version = "4.8.0"  # Update to latest version
```

### Scaling

Adjust replicas based on load:

```hcl
controller_replicas = 3  # Increase for high traffic
```

### Resource Tuning

Monitor resource usage and adjust limits:

```hcl
controller_cpu_limit = "500m"      # Increase if CPU bound
controller_memory_limit = "512Mi"  # Increase if memory bound
``` 