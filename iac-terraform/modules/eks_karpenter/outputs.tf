# EKS Karpenter Module - Outputs

output "karpenter_controller_role_arn" {
  description = "Karpenter controller IAM role ARN"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  description = "Karpenter node IAM role ARN"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_instance_profile_name" {
  description = "Karpenter node instance profile name"
  value       = aws_iam_instance_profile.karpenter_node.name
}

output "karpenter_queue_name" {
  description = "Karpenter SQS queue name"
  value       = aws_sqs_queue.karpenter.name
}

output "karpenter_queue_arn" {
  description = "Karpenter SQS queue ARN"
  value       = aws_sqs_queue.karpenter.arn
} 