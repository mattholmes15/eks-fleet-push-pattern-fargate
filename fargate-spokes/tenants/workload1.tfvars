region             = "eu-west-2"
vpc_name           = "vpc-0a7d25e7a6e2fe05c" #TODO Update this
kubernetes_version = "1.30"
cluster_type       = "workload"
tenant             = "tenant1"
addons = {
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
}
manifests = {
  enable_external_secrets_secrets = false
}
# Addons Git
# addons_repo_url        = "https://github.com/eks-fleet-management/gitops-addons.git"
# addons_repo_basepath   = ""
# addons_repo_path       = "bootstrap/addons"
# addons_repo_revision   = "gitops-v1"
# # addons_repo_secret_key = var.secret_name_git_data_addons
# # Manifests Git
# manifests_repo_url        = "https://github.com/eks-fleet-management/gitops-addons.git"
# manifests_repo_basepath   = ""
# manifests_repo_path       = "bootstrap/manifests"
# manifests_repo_revision   = "gitops-v1"
# manifests_manifests_basepath = ""
