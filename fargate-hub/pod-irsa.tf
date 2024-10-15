################################################################################
# External Secrets EKS Access
################################################################################
module "external_secrets_irsa" {
  count   = local.aws_addons.enable_external_secrets ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "external-secrets-irsa"

  role_policy_arns = {
    policy = aws_iam_policy.external_secrets_ecr_policy.arn
  }

  attach_external_secrets_policy        = true
  external_secrets_ssm_parameter_arns   = ["arn:aws:ssm:*:*:parameter/*"]
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:*"]
  external_secrets_kms_key_arns         = ["arn:aws:kms:*:*:key/*"]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.external_secrets.namespace}:${local.external_secrets.service_account}"]
    }
  }

  tags = local.tags
}

#NEW Added
resource "aws_iam_policy" "external_secrets_ecr_policy" {
  name        = "external-secrets-policy"
  path        = "/"
  description = "IAM policy for External Secrets to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:getAuthorizationToken",
        ]
        Resource = "*"
      }
    ]
  })
}

################################################################################
# CloudWatch Observability EKS Access
################################################################################
module "aws_cloudwatch_observability_irsa" {
  count   = local.aws_addons.enable_aws_cloudwatch_observability ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "aws-cloudwatch-observability-irsa"

  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }

  tags = local.tags
}

################################################################################
# EFS CSI EKS Access
################################################################################
module "aws_efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "aws-efs-csi-irsa"

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

################################################################################
# AWS ALB Ingress Controller EKS Access
################################################################################
module "aws_lb_controller_irsa" {
  count   = local.aws_addons.enable_aws_load_balancer_controller ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "aws-lb-controller-irsa"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.aws_load_balancer_controller.namespace}:${local.aws_load_balancer_controller.service_account}"]
    }
  }

  tags = local.tags
}

################################################################################
# ArgoCD EKS Access
################################################################################
module "argocd_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "argocd-irsa"

  role_policy_arns = {
    assume_policy         = aws_iam_policy.argocd_assume_policy.arn,
    secretsmanager_policy = aws_iam_policy.argocd_secretsmanager_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argocd:argocd-application-controller", "argocd:argocd-server"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "argocd_assume_policy" {
  name        = "argocd-assume-policy"
  path        = "/"
  description = "IAM policy for ArgoCD"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Resource = "*"
      }
    ]
  })
}

#NEW to read spoke secrets created in the hub account
resource "aws_iam_policy" "argocd_secretsmanager_policy" {
  name        = "argocd-secretsmanager-policy"
  path        = "/"
  description = "IAM policy for Secretsmanager to read Spoke secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:hub-cluster-fargate/*"
      },
    ]
  })
}
