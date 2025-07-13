# IAM Module - Main Configuration
# Creates IAM users, groups, roles, and policy attachments

# IAM Groups
resource "aws_iam_group" "devops" {
  name = "${var.environment}-devops"
  path = "/"
}

resource "aws_iam_group" "developers" {
  name = "${var.environment}-developers"
  path = "/"
}

resource "aws_iam_group" "qa" {
  name = "${var.environment}-qa"
  path = "/"
}

resource "aws_iam_group" "readonly" {
  name = "${var.environment}-readonly"
  path = "/"
}

# IAM Users
resource "aws_iam_user" "devops_users" {
  for_each = var.devops_users

  name = each.value.name
  path = "/"

  tags = merge(var.tags, {
    Name        = each.value.name
    Environment = var.environment
    Group       = "devops"
  })
}

resource "aws_iam_user" "developer_users" {
  for_each = var.developer_users

  name = each.value.name
  path = "/"

  tags = merge(var.tags, {
    Name        = each.value.name
    Environment = var.environment
    Group       = "developers"
  })
}

resource "aws_iam_user" "qa_users" {
  for_each = var.qa_users

  name = each.value.name
  path = "/"

  tags = merge(var.tags, {
    Name        = each.value.name
    Environment = var.environment
    Group       = "qa"
  })
}

resource "aws_iam_user" "readonly_users" {
  for_each = var.readonly_users

  name = each.value.name
  path = "/"

  tags = merge(var.tags, {
    Name        = each.value.name
    Environment = var.environment
    Group       = "readonly"
  })
}

# Group Memberships
resource "aws_iam_group_membership" "devops" {
  name = "${var.environment}-devops-membership"
  users = [
    for user in aws_iam_user.devops_users : user.name
  ]
  group = aws_iam_group.devops.name
}

resource "aws_iam_group_membership" "developers" {
  name = "${var.environment}-developers-membership"
  users = [
    for user in aws_iam_user.developer_users : user.name
  ]
  group = aws_iam_group.developers.name
}

resource "aws_iam_group_membership" "qa" {
  name = "${var.environment}-qa-membership"
  users = [
    for user in aws_iam_user.qa_users : user.name
  ]
  group = aws_iam_group.qa.name
}

resource "aws_iam_group_membership" "readonly" {
  name = "${var.environment}-readonly-membership"
  users = [
    for user in aws_iam_user.readonly_users : user.name
  ]
  group = aws_iam_group.readonly.name
}

# Custom IAM Policies
resource "aws_iam_policy" "ci_cd_pipeline" {
  name        = "${var.environment}-ci-cd-pipeline-policy"
  path        = "/"
  description = "CI/CD pipeline policy with least privilege access"

  policy = file("${path.root}/policies/ci_cd_pipeline.json")

  tags = merge(var.tags, {
    Name = "${var.environment}-ci-cd-pipeline-policy"
  })
}

resource "aws_iam_policy" "eks_read_write" {
  name        = "${var.environment}-eks-read-write-policy"
  path        = "/"
  description = "EKS read-write policy for developers"

  policy = file("${path.root}/policies/eks_read_write.json")

  tags = merge(var.tags, {
    Name = "${var.environment}-eks-read-write-policy"
  })
}

resource "aws_iam_policy" "read_only" {
  name        = "${var.environment}-read-only-policy"
  path        = "/"
  description = "Read-only policy for QA and readonly users"

  policy = file("${path.root}/policies/read_only.json")

  tags = merge(var.tags, {
    Name = "${var.environment}-read-only-policy"
  })
}

# Developer S3 Access Policy (for dev environment)
resource "aws_iam_policy" "developer_s3_access" {
  count = var.environment == "dev" ? 1 : 0

  name        = "${var.environment}-developer-s3-access-policy"
  path        = "/"
  description = "S3 access policy for developers in dev environment"

  policy = file("${path.root}/policies/developer_s3_access.json")

  tags = merge(var.tags, {
    Name = "${var.environment}-developer-s3-access-policy"
  })
}

# Group Policy Attachments
resource "aws_iam_group_policy_attachment" "devops_admin" {
  group      = aws_iam_group.devops.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "devops_ci_cd" {
  group      = aws_iam_group.devops.name
  policy_arn = aws_iam_policy.ci_cd_pipeline.arn
}

resource "aws_iam_group_policy_attachment" "developers_power_user" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_group_policy_attachment" "developers_eks" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.eks_read_write.arn
}

# Attach S3 access policy to developers group (dev environment only)
resource "aws_iam_group_policy_attachment" "developers_s3_access" {
  count = var.environment == "dev" ? 1 : 0

  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_s3_access[0].arn
}

resource "aws_iam_group_policy_attachment" "qa_read_only" {
  group      = aws_iam_group.qa.name
  policy_arn = aws_iam_policy.read_only.arn
}

resource "aws_iam_group_policy_attachment" "readonly_read_only" {
  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.read_only.arn
}

# CI/CD Pipeline Role
resource "aws_iam_role" "ci_cd_pipeline" {
  name = "${var.environment}-ci-cd-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = var.github_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_repository_subjects
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-ci-cd-pipeline-role"
  })
}

resource "aws_iam_role_policy_attachment" "ci_cd_pipeline" {
  role       = aws_iam_role.ci_cd_pipeline.name
  policy_arn = aws_iam_policy.ci_cd_pipeline.arn
}

# Create access keys for users (required for programmatic access)
resource "aws_iam_access_key" "devops_users" {
  for_each = var.create_access_keys ? var.devops_users : {}

  user = aws_iam_user.devops_users[each.key].name
}

resource "aws_iam_access_key" "developer_users" {
  for_each = var.create_access_keys ? var.developer_users : {}

  user = aws_iam_user.developer_users[each.key].name
}

resource "aws_iam_access_key" "qa_users" {
  for_each = var.create_access_keys ? var.qa_users : {}

  user = aws_iam_user.qa_users[each.key].name
}

resource "aws_iam_access_key" "readonly_users" {
  for_each = var.create_access_keys ? var.readonly_users : {}

  user = aws_iam_user.readonly_users[each.key].name
}

# Password Policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = var.password_policy.minimum_length
  require_lowercase_characters   = var.password_policy.require_lowercase
  require_numbers                = var.password_policy.require_numbers
  require_uppercase_characters   = var.password_policy.require_uppercase
  require_symbols                = var.password_policy.require_symbols
  allow_users_to_change_password = var.password_policy.allow_users_to_change
  hard_expiry                    = var.password_policy.hard_expiry
  max_password_age               = var.password_policy.max_age
  password_reuse_prevention      = var.password_policy.reuse_prevention
}

# MFA enforcement policy (optional)
resource "aws_iam_policy" "enforce_mfa" {
  count = var.enforce_mfa ? 1 : 0

  name        = "${var.environment}-enforce-mfa-policy"
  path        = "/"
  description = "Enforce MFA for all users"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:GetAccountSummary",
          "iam:ListVirtualMFADevices"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnPasswords"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetUser"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:mfa/$${aws:username}",
          "arn:aws:iam::*:user/$${aws:username}"
        ]
      },
      {
        Sid    = "DenyAllExceptUnlessMFAAuthenticated"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-enforce-mfa-policy"
  })
}

# Attach MFA policy to all groups
resource "aws_iam_group_policy_attachment" "devops_mfa" {
  count = var.enforce_mfa ? 1 : 0

  group      = aws_iam_group.devops.name
  policy_arn = aws_iam_policy.enforce_mfa[0].arn
}

resource "aws_iam_group_policy_attachment" "developers_mfa" {
  count = var.enforce_mfa ? 1 : 0

  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.enforce_mfa[0].arn
}

resource "aws_iam_group_policy_attachment" "qa_mfa" {
  count = var.enforce_mfa ? 1 : 0

  group      = aws_iam_group.qa.name
  policy_arn = aws_iam_policy.enforce_mfa[0].arn
}

resource "aws_iam_group_policy_attachment" "readonly_mfa" {
  count = var.enforce_mfa ? 1 : 0

  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.enforce_mfa[0].arn
} 