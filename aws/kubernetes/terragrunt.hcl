##
# (c) 2022-2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  local_vars   = yamldecode(file("./inputs.yaml"))
  base_vars    = yamldecode(file("./inputs-global.yaml"))
  release_vars = yamldecode(file("./release.yaml"))
  global_vars  = yamldecode(file(find_in_parent_folders("global-inputs.yaml")))
  values_file  = "./helm-values.yaml"
}

include {
  path = find_in_parent_folders()
}

generate "kubernetes_provider" {
  path      = "provider.l.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "cluster" {
  name = "${local.local_vars.cluster_name}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${local.local_vars.cluster_name}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
EOF
}

terraform {
  source = "github.com/cloudopsworks/terraform-module-aws-eks-helm-deploy.git//?ref=master"
}

inputs = {
  org = {
    organization_name = local.base_vars.organization_name
    organization_unit = local.base_vars.organization_unit
    environment_name  = local.base_vars.environment_name
    environment_type  = local.local_vars.environment
  }
  repository_owner = local.base_vars.repository_owner
  region           = local.global_vars.default.region
  sts_assume_role  = local.global_vars.default.sts_role_arn
  release          = local.release_vars.release
  namespace        = local.local_vars.namespace
  cluster_name     = local.local_vars.cluster_name
  helm_repo_url    = try(local.local_vars.helm_repo_url, "")
  helm_chart_name  = try(local.local_vars.helm_chart_name, "")
  helm_chart_path  = try(local.local_vars.helm_chart_path, "")
  values_file      = local.values_file
  values_overrides = merge(
    local.local_vars.helm_values_overrides,
    {
      "image.tag" = local.release_vars.release.source.version
    }
  )
  container_registry = local.local_vars.container_registry
  config_map         = local.local_vars.config_map
  secrets            = local.local_vars.aws
  absolute_path      = get_terragrunt_dir()
  extra_tags         = try(local.local_vars.tags, {})
}