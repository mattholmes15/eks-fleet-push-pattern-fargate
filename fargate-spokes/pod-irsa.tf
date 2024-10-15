################################################################################
# CloudWatch Observability EKS Access
################################################################################
module "aws_cloudwatch_observability_irsa" {
  count   = local.aws_addons.enable_aws_cloudwatch_observability ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.46.0"

  role_name = "aws-cloudwatch-observability-spoke-irsa"

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
# External Secrets EKS Access
################################################################################
module "external_secrets_irsa" {
  count   = local.aws_addons.enable_external_secrets ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "external-secrets-spoke-irsa"

  attach_external_secrets_policy = true
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

################################################################################
# AWS ALB Ingress Controller EKS Access
################################################################################
module "aws_lb_controller_irsa" {
  count   = local.aws_addons.enable_aws_load_balancer_controller ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.46.0"

  role_name = "aws-lb-controller-spoke-irsa"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.aws_load_balancer_controller.namespace}:${local.aws_load_balancer_controller.service_account}"]
    }
  }

  tags = local.tags
}

