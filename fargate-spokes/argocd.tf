################################################################################
# ArgoCD EKS Access
################################################################################
data "aws_ssm_parameter" "argocd_hub_role" {
  provider = aws.shared-services
  name     = "/fleet-hub/argocd-hub-role-fargate"
}

resource "aws_iam_role" "spoke" {
  name               = "${local.name}-argocd-spoke"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_ssm_parameter.argocd_hub_role.value]
    }
  }
}


################################################################################
# Secret Required to Register spoke to HUB
################################################################################
resource "aws_secretsmanager_secret" "spoke_cluster_secret" { 
  provider                = aws.shared-services #FYI created in the hub cluster
  name                    = "hub-cluster-fargate/${local.name}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd_cluster_secret_version" {
  provider  = aws.shared-services
  secret_id = aws_secretsmanager_secret.spoke_cluster_secret.id
  secret_string = jsonencode({
    cluster_name = module.eks.cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
    server       = module.eks.cluster_endpoint
    config = {
      tlsClientConfig = {
        insecure = false,
        caData   = module.eks.cluster_certificate_authority_data
      },
      awsAuthConfig = {
        clusterName = module.eks.cluster_name,
        region      = "eu-west-2"
        roleARN     = aws_iam_role.spoke.arn
      }
    }
  })
}
