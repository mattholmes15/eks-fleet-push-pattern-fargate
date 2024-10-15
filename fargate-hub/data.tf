data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_ecr_authorization_token" "token" {}
# data "aws_ecrpublic_authorization_token" "token" {
#   provider = aws.public-ecr
# }
# data "aws_iam_session_context" "current" { #TODO Uncomment once moved across
#   # This data source provides information on the IAM source role of an STS assumed role
#   # For non-role ARNs, this data source simply passes the ARN through issuer ARN
#   # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
#   # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
#   arn = data.aws_caller_identity.current.arn
# }

data "aws_iam_roles" "eks_admin_role" {
  name_regex = "AWSReservedSSO_AdministratorAccess_.*"
}

# data "aws_route53_zone" "selected" {
#   name = var.route53_zone_name
# }

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["matt-eks-vpc"] #TODO update references
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    Name = "matt-eks-vpc-private-*" #TODO update references
  }
}
