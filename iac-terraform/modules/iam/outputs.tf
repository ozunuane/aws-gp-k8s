# IAM Module - Outputs

# Group Outputs
output "devops_group_name" {
  description = "DevOps group name"
  value       = aws_iam_group.devops.name
}

output "developers_group_name" {
  description = "Developers group name"
  value       = aws_iam_group.developers.name
}

output "qa_group_name" {
  description = "QA group name"
  value       = aws_iam_group.qa.name
}

output "readonly_group_name" {
  description = "Read-only group name"
  value       = aws_iam_group.readonly.name
}

# User Outputs
output "devops_user_names" {
  description = "List of DevOps user names"
  value       = [for user in aws_iam_user.devops_users : user.name]
}

output "developer_user_names" {
  description = "List of Developer user names"
  value       = [for user in aws_iam_user.developer_users : user.name]
}

output "qa_user_names" {
  description = "List of QA user names"
  value       = [for user in aws_iam_user.qa_users : user.name]
}

output "readonly_user_names" {
  description = "List of Read-only user names"
  value       = [for user in aws_iam_user.readonly_users : user.name]
}

# Policy Outputs
output "ci_cd_pipeline_policy_arn" {
  description = "CI/CD pipeline policy ARN"
  value       = aws_iam_policy.ci_cd_pipeline.arn
}

output "eks_read_write_policy_arn" {
  description = "EKS read-write policy ARN"
  value       = aws_iam_policy.eks_read_write.arn
}

output "read_only_policy_arn" {
  description = "Read-only policy ARN"
  value       = aws_iam_policy.read_only.arn
}

output "developer_s3_access_policy_arn" {
  description = "Developer S3 access policy ARN (dev environment only)"
  value       = var.environment == "dev" ? aws_iam_policy.developer_s3_access[0].arn : null
}

# Role Outputs
output "ci_cd_pipeline_role_arn" {
  description = "CI/CD pipeline role ARN"
  value       = aws_iam_role.ci_cd_pipeline.arn
}

output "ci_cd_pipeline_role_name" {
  description = "CI/CD pipeline role name"
  value       = aws_iam_role.ci_cd_pipeline.name
}

# Access Key Outputs (sensitive)
output "devops_access_keys" {
  description = "DevOps users access keys"
  value = {
    for key, user in aws_iam_access_key.devops_users : key => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true
}

output "developer_access_keys" {
  description = "Developer users access keys"
  value = {
    for key, user in aws_iam_access_key.developer_users : key => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true
}

output "qa_access_keys" {
  description = "QA users access keys"
  value = {
    for key, user in aws_iam_access_key.qa_users : key => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true
}

output "readonly_access_keys" {
  description = "Read-only users access keys"
  value = {
    for key, user in aws_iam_access_key.readonly_users : key => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true
} 