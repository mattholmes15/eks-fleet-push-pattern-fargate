provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = [
        "eks",
        "get-token",
        "--cluster-name", module.eks.cluster_name,
        "--region", local.region,
        #"--role-arn", "arn:aws:iam::${local.account_config.account_id}:role/cross-account-role"
      ]
    }
  }
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = [
      "eks",
      "get-token",
      "--cluster-name", module.eks.cluster_name,
      "--region", local.region,
      #"--role-arn", "arn:aws:iam::${local.account_config.account_id}:role/cross-account-role"
    ]
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = [
      "eks",
      "get-token",
      "--cluster-name", module.eks.cluster_name,
      "--region", local.region,
      #"--role-arn", "arn:aws:iam::${local.account_config.account_id}:role/cross-account-role"
    ]
  }
}


provider "aws" {
  region = "eu-west-2"
  # assume_role {
  #   role_arn     = "arn:aws:iam::${local.account_config.account_id}:role/cross-account-role"
  #   session_name = "cross-account"
  # }
}

provider "aws" {
  alias  = "shared-services"
  region = "eu-west-2"
  # assume_role {
  #   role_arn     = "arn:aws:iam::${var.env_config["shared-shervices"].account_id}:role/cross-account-role"
  #   session_name = "shared-shervices"
  # }
}

provider "aws" {
  region = "us-east-1"
  alias  = "public-ecr"
}

# terraform {
#   # backend "s3" {
#   #   bucket  = "hub-spoke-push-mk"
#   #   key     = "hub-spoke-push/hub/terraform.tfstate"
#   #   region  = "eu-west-2"
#   #   encrypt = true
#   # }
# }

