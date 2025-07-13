# EKS Karpenter Module - Main Configuration
# Creates Karpenter with cost-optimized mixed on-demand and spot instances

# Karpenter Installation
resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = var.karpenter_version
  namespace        = "karpenter"
  create_namespace = true

  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter_node.name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = aws_sqs_queue.karpenter.name
  }

  depends_on = [
    aws_iam_role.karpenter_controller,
    aws_iam_instance_profile.karpenter_node,
    aws_sqs_queue.karpenter,
  ]
}

# Karpenter Controller IAM Role
resource "aws_iam_role" "karpenter_controller" {
  name = "${var.environment}-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-karpenter-controller-role"
  })
}

# Karpenter Controller IAM Policy
resource "aws_iam_role_policy" "karpenter_controller" {
  name = "${var.environment}-karpenter-controller-policy"
  role = aws_iam_role.karpenter_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "pricing:GetProducts",
          "ssm:GetParameter"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = var.cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.karpenter_node.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ]
        Resource = aws_sqs_queue.karpenter.arn
      }
    ]
  })
}

# Karpenter Node IAM Role
resource "aws_iam_role" "karpenter_node" {
  name = "${var.environment}-karpenter-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-karpenter-node-role"
  })
}

# Karpenter Node IAM Policy Attachments
resource "aws_iam_role_policy_attachment" "karpenter_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter_node.name
}

# Karpenter Node Instance Profile
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "${var.environment}-karpenter-node-instance-profile"
  role = aws_iam_role.karpenter_node.name

  tags = merge(var.tags, {
    Name = "${var.environment}-karpenter-node-instance-profile"
  })
}

# SQS Queue for Karpenter interruption handling
resource "aws_sqs_queue" "karpenter" {
  name                      = "${var.environment}-karpenter"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true

  tags = merge(var.tags, {
    Name = "${var.environment}-karpenter-queue"
  })
}

# SQS Queue Policy
resource "aws_sqs_queue_policy" "karpenter" {
  queue_url = aws_sqs_queue.karpenter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "events.amazonaws.com",
            "sqs.amazonaws.com"
          ]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter.arn
      }
    ]
  })
}

# EventBridge Rules for Spot Instance Interruption
resource "aws_cloudwatch_event_rule" "karpenter_spot_interruption" {
  name        = "${var.environment}-karpenter-spot-interruption"
  description = "Capture spot instance interruption warnings"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Spot Instance Interruption Warning"]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-karpenter-spot-interruption"
  })
}

resource "aws_cloudwatch_event_target" "karpenter_spot_interruption" {
  rule      = aws_cloudwatch_event_rule.karpenter_spot_interruption.name
  target_id = "KarpenterSpotInterruptionTarget"
  arn       = aws_sqs_queue.karpenter.arn
}

# EventBridge Rules for Instance State Changes
resource "aws_cloudwatch_event_rule" "karpenter_instance_state_change" {
  name        = "${var.environment}-karpenter-instance-state-change"
  description = "Capture instance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-karpenter-instance-state-change"
  })
}

resource "aws_cloudwatch_event_target" "karpenter_instance_state_change" {
  rule      = aws_cloudwatch_event_rule.karpenter_instance_state_change.name
  target_id = "KarpenterInstanceStateChangeTarget"
  arn       = aws_sqs_queue.karpenter.arn
}

# Karpenter Provisioner for Critical Workloads (On-Demand)
resource "kubectl_manifest" "karpenter_provisioner_critical" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "critical-workloads"
    }
    spec = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["on-demand"]
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = var.critical_instance_types
        }
      ]
      limits = {
        resources = {
          cpu = var.critical_cpu_limit
        }
      }
      providerRef = {
        name = "critical-workloads"
      }
      taints = [
        {
          key    = "workload-type"
          value  = "critical"
          effect = "NoSchedule"
        }
      ]
      ttlSecondsAfterEmpty = 30
    }
  })

  depends_on = [helm_release.karpenter]
}

# Karpenter AWSNodePool for Critical Workloads
resource "kubectl_manifest" "karpenter_nodepool_critical" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "AWSNodePool"
    metadata = {
      name = "critical-workloads"
    }
    spec = {
      amiFamily = "AL2"
      role      = aws_iam_role.karpenter_node.name
      securityGroupSelectorTerms = [
        {
          tags = {
            "aws:eks:cluster-name" = var.cluster_name
          }
        }
      ]
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      userData = base64encode(templatefile("${path.module}/userdata.sh", {
        cluster_name = var.cluster_name
      }))
    }
  })

  depends_on = [helm_release.karpenter]
}

# Karpenter Provisioner for Non-Critical Workloads (Spot + On-Demand)
resource "kubectl_manifest" "karpenter_provisioner_non_critical" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "non-critical-workloads"
    }
    spec = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["spot", "on-demand"]
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = var.non_critical_instance_types
        }
      ]
      limits = {
        resources = {
          cpu = var.non_critical_cpu_limit
        }
      }
      providerRef = {
        name = "non-critical-workloads"
      }
      taints = [
        {
          key    = "workload-type"
          value  = "non-critical"
          effect = "NoSchedule"
        }
      ]
      ttlSecondsAfterEmpty = 30
    }
  })

  depends_on = [helm_release.karpenter]
}

# Karpenter AWSNodePool for Non-Critical Workloads
resource "kubectl_manifest" "karpenter_nodepool_non_critical" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "AWSNodePool"
    metadata = {
      name = "non-critical-workloads"
    }
    spec = {
      amiFamily = "AL2"
      role      = aws_iam_role.karpenter_node.name
      securityGroupSelectorTerms = [
        {
          tags = {
            "aws:eks:cluster-name" = var.cluster_name
          }
        }
      ]
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      userData = base64encode(templatefile("${path.module}/userdata.sh", {
        cluster_name = var.cluster_name
      }))
    }
  })

  depends_on = [helm_release.karpenter]
} 