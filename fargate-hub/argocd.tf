################################################################################
# GitOps Bridge: Private ssh keys for git
################################################################################
resource "kubernetes_namespace" "argocd" {
  depends_on = [module.eks]
  metadata {
    name = local.argocd_namespace
  }
}
resource "kubernetes_secret" "git_secrets" {
  depends_on = [kubernetes_namespace.argocd]
  for_each = {
    git-addons = {
      type     = "git"
      url      = "https://github.com/mattholmes15/gitops-addons.git"
      username = "git"
      password = var.github_token
    }
    argocd-bitnami = {
      type      = "helm"
      url       = "charts.bitnami.com/bitnami"
      name      = "Bitnami"
      enableOCI = true
    }
    argocd-ecr-credentials = {
      type      = "helm"
      url       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com"
      name      = "ecr-charts"
      enableOCI = true
      username  = "AWS"
      password  = data.aws_ecr_authorization_token.token.password
    }
  }
  metadata {
    name      = each.key
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = each.value
}

# Creating parameter for argocd hub role for the spoke clusters to read
resource "aws_ssm_parameter" "argocd_hub_role" {
  name  = "/fleet-hub/argocd-hub-role-fargate"
  type  = "String"
  value = module.argocd_irsa.iam_role_arn
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source  = "gitops-bridge-dev/gitops-bridge/helm"
  version = "0.1.0"
  cluster = {
    cluster_name = module.eks.cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps
  argocd = {
    name          = "argocd"
    namespace     = local.argocd_namespace
    chart_version = "7.6.5"
    values = [
      templatefile("${path.module}/argocd-initial-values.yaml", {
        ARGOCD_IRSA_ROLE_ARN = module.argocd_irsa.iam_role_arn
      })
    ]
    timeout          = 600
    create_namespace = false
  }
  depends_on = [kubernetes_secret.git_secrets]
}

resource "kubernetes_secret" "github_access" {
  depends_on = [kubernetes_namespace.argocd]
  metadata {
    name      = "github-access"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = "https://github.com/mattholmes15/gitops-addons.git"
    username = "git"
    password = var.github_token
  }
}
