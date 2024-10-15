locals {
  name             = "hub-cluster-fargate"
  environment      = "control-plane"
  fleet_member     = "control-plane"
  tenant           = "control-plane"
  region           = data.aws_region.current.id
  cluster_version  = var.kubernetes_version
  argocd_namespace = "argocd"

  external_secrets = {
    namespace       = "external-secrets"
    service_account = "external-secrets-sa"
  }
  aws_load_balancer_controller = {
    namespace       = "kube-system"
    service_account = "aws-load-balancer-controller-sa"
  }

  external_dns = {
    namespace       = "external-dns"
    service_account = "external-dns-sa"
    domain_filters  = "eks.kandylis.co.uk"
  }

  aws_addons = {
    enable_cert_manager                          = try(var.addons.enable_cert_manager, false)
    enable_aws_efs_csi_driver                    = try(var.addons.enable_aws_efs_csi_driver, false)
    enable_aws_fsx_csi_driver                    = try(var.addons.enable_aws_fsx_csi_driver, false)
    enable_aws_cloudwatch_metrics                = try(var.addons.enable_aws_cloudwatch_metrics, false)
    enable_aws_cloudwatch_observability          = try(var.addons.enable_aws_cloudwatch_observability, false)
    enable_aws_privateca_issuer                  = try(var.addons.enable_aws_privateca_issuer, false)
    enable_cluster_autoscaler                    = try(var.addons.enable_cluster_autoscaler, false)
    enable_external_dns                          = try(var.addons.enable_external_dns, false)
    enable_external_secrets                      = try(var.addons.enable_external_secrets, false)
    enable_aws_load_balancer_controller          = try(var.addons.enable_aws_load_balancer_controller, false)
    enable_fargate_fluentbit                     = try(var.addons.enable_fargate_fluentbit, false)
    enable_aws_for_fluentbit                     = try(var.addons.enable_aws_for_fluentbit, false)
    enable_aws_node_termination_handler          = try(var.addons.enable_aws_node_termination_handler, false)
    enable_karpenter                             = try(var.addons.enable_karpenter, false)
    enable_velero                                = try(var.addons.enable_velero, false)
    enable_aws_gateway_api_controller            = try(var.addons.enable_aws_gateway_api_controller, false)
    enable_aws_ebs_csi_resources                 = try(var.addons.enable_aws_ebs_csi_resources, false)
    enable_aws_secrets_store_csi_driver_provider = try(var.addons.enable_aws_secrets_store_csi_driver_provider, false)
    enable_ack_apigatewayv2                      = try(var.addons.enable_ack_apigatewayv2, false)
    enable_ack_dynamodb                          = try(var.addons.enable_ack_dynamodb, false)
    enable_ack_s3                                = try(var.addons.enable_ack_s3, false)
    enable_ack_rds                               = try(var.addons.enable_ack_rds, false)
    enable_ack_prometheusservice                 = try(var.addons.enable_ack_prometheusservice, false)
    enable_ack_emrcontainers                     = try(var.addons.enable_ack_emrcontainers, false)
    enable_ack_sfn                               = try(var.addons.enable_ack_sfn, false)
    enable_ack_eventbridge                       = try(var.addons.enable_ack_eventbridge, false)
    enable_aws_argocd                            = try(var.addons.enable_aws_argocd, false)
  }
  oss_addons = {
    enable_argocd                          = try(var.addons.enable_argocd, false)
    enable_argo_rollouts                   = try(var.addons.enable_argo_rollouts, false)
    enable_argo_events                     = try(var.addons.enable_argo_events, false)
    enable_argo_workflows                  = try(var.addons.enable_argo_workflows, false)
    enable_cluster_proportional_autoscaler = try(var.addons.enable_cluster_proportional_autoscaler, false)
    enable_gatekeeper                      = try(var.addons.enable_gatekeeper, false)
    enable_gpu_operator                    = try(var.addons.enable_gpu_operator, false)
    enable_ingress_nginx                   = try(var.addons.enable_ingress_nginx, false)
    enable_keda                            = try(var.addons.enable_keda, false)
    enable_kyverno                         = try(var.addons.enable_kyverno, false)
    enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
    enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
    enable_secrets_store_csi_driver        = try(var.addons.enable_secrets_store_csi_driver, false)
    enable_vpa                             = try(var.addons.enable_vpa, false)
  }

  manifests = {
    enable_external_secrets_manifests = try(var.manifests.enable_external_secrets_manifests, false)
  }

  addons = merge(
    local.aws_addons,
    local.oss_addons,
    local.manifests,
    { tenant = local.tenant },
    { fleet_member = local.fleet_member },
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = module.eks.cluster_name },
  )
  addons_metadata = merge(
    module.eks_blueprints_addons.gitops_metadata,
    {
      aws_cluster_name = module.eks.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = data.aws_vpc.vpc.id
    },
    {
      argocd_namespace        = local.argocd_namespace,
      create_argocd_namespace = false
    },
    {
      addons_repo_url      = "https://github.com/mattholmes15/gitops-addons.git"
      addons_repo_basepath = ""
      addons_repo_path     = "bootstrap/addons"
      addons_repo_revision = "main"
      # addons_repo_secret_key = var.secret_name_git_data_addons
    },
    # Setings of the gitops manifests repo
    {
      manifests_repo_url           = "https://github.com/mattholmes15/gitops-addons.git"
      manifests_repo_basepath      = ""
      manifests_repo_path          = "bootstrap/manifests"
      manifests_repo_revision      = "main"
      manifests_manifests_basepath = ""
    },
    {
      fleet_repo_url      = "https://github.com/mattholmes15/gitops-addons.git"
      fleet_repo_basepath = ""
      fleet_repo_path     = "bootstrap/fleet"
      fleet_repo_revision = "main"
    },
    {
      external_dns_namespace       = local.external_dns.namespace #TODO nothing done with External DNS as of yet
      external_dns_domain_filters  = local.external_dns.domain_filters 
      external_dns_service_account = local.external_dns.service_account
      #external_dns_iam_role_arn     = module.external_dns_irsa[0].iam_role_arn
    },
    {
      external_secrets_namespace       = local.external_secrets.namespace
      external_secrets_service_account = local.external_secrets.service_account
      external_secrets_iam_role_arn    = module.external_secrets_irsa[0].iam_role_arn
    },
    {
      aws_load_balancer_controller_namespace       = local.aws_load_balancer_controller.namespace
      aws_load_balancer_controller_service_account = local.aws_load_balancer_controller.service_account
      aws_load_balancer_controller_iam_role_arn    = module.aws_lb_controller_irsa[0].iam_role_arn
    }
  )

  argocd_apps = {
    addons    = file("${path.module}/bootstrap/addons.yaml")
    manifests = file("${path.module}/manifests/manifests.yaml")
    fleet     = file("${path.module}/fleet/fleet.yaml") #TODO MH Added this - is this correct?

  }
  role_arns = []
  # # Generate dynamic access entries for each admin rolelocals {
  admin_access_entries = {
    for role_arn in local.role_arns : role_arn => {
      principal_arn = role_arn
      policy_associations = {
        admins = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }


  # Merging dynamic entries with static entries if needed
  access_entries = merge({}, local.admin_access_entries)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/gitops-bridge-dev/gitops-bridge"
  }
}


