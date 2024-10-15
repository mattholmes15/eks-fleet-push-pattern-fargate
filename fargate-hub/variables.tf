variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "kms_key_admin_roles" {
  description = "list of role ARNs to add to the KMS policy"
  type        = list(string)
  default     = []
}

# variable "env_config" {
#   description = "Map of objects for per environment configuration"
#   type = map(object({
#     account_id = string
#   }))
# }

variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_metrics_server               = true
    enable_argocd                       = true
    enable_aws_load_balancer_controller = true
    enable_external_secrets             = true
    enable_fargate_fluentbit            = false
    enable_kyverno                      = false
    enable_external_dns                 = false
    enable_aws_efs_csi_driver           = false
  }
}

variable "enable_addon_selector" {
  description = "select addons using cluster selector"
  type        = bool
  default     = false
}

variable "route53_zone_name" {
  description = "The route53 zone for external dns"
  default     = "eks.kandylis.co.uk"
}

variable "manifests" {
  description = "Kubernetes manifests"
  type        = any
  default = {
    enable_external_secrets_manifests = true
  }
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}
