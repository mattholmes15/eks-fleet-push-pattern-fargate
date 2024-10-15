variable "kubernetes_version" {
  description = "EKS version"
  type        = string
}

variable "addons" {
  description = "EKS addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = true
    enable_metrics_server               = true
  }
}

variable "kms_key_admin_roles" {
  description = "list of role ARNs to add to the KMS policy"
  type        = list(string)
  default     = []

}

variable "route53_zone_name" {
  description = "the Name of Route53 zone for external dns"
  type        = string
  default     = ""
}


# variable "env_config" {
#   description = "Map of objects for per environment configuration"
#   type = map(object({
#     account_id = string
#   }))
# }

# variable "default_env_config" {
#   description = "The Default account ids that need to deploy resources to shared services account"
#   type = map(object({
#     account_id = string
#   }))
# }

variable "tenant" {
  description = "Name of the tenant where the cluster belongs to"
  type        = string
}

variable "cluster_type" {
  description = "The type of cluster if it belong to tenant or to platorfom team"
  type        = string
}

variable "vpc_name" {
  description = "The prefix name of the vpc for the data to loof for it"
  type        = string
}

variable "env_config" {
  description = "Map of objects for per environment configuration"
  type = map(object({
    account_id = string
  }))
}
variable "manifests" {
  description = "Kubernetes manifests"
  type        = any
  default = {
    enable_external_secrets_manifests = false
  }
}
