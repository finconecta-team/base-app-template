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
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/cloudopsworks/terraform-module-aws-elasticbeanstalk-deploy.git//?ref=master"
}

inputs = {
  org = {
    organization_name = local.base_vars.organization_name
    organization_unit = local.base_vars.organization_unit
    environment_name  = local.base_vars.environment_name
    environment_type  = local.local_vars.environment
  }
  repository_owner = local.base_vars.repository_owner
  namespace        = local.local_vars.environment
  versions_bucket  = local.local_vars.versions_bucket
  logs_bucket      = try(local.local_vars.logs_bucket, "")
  region           = local.global_vars.default.region
  sts_assume_role  = local.global_vars.default.sts_role_arn
  beanstalk        = local.local_vars.beanstalk
  dns              = local.local_vars.dns
  api_gateway      = local.local_vars.api_gateway
  alarms           = local.local_vars.alarms
  release          = local.release_vars.release
  absolute_path    = get_terragrunt_dir()
  extra_tags       = try(local.local_vars.tags, {})
}