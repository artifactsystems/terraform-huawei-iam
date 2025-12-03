provider "huaweicloud" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "tr-west-"
}

################################################################################
# Data Sources - Get Role IDs
################################################################################

data "huaweicloud_identity_role" "rds_readonly" {
  display_name = "RDS ReadOnlyAccess"
}

################################################################################
# IAM Module
################################################################################

module "iam" {
  source = "../../"

  users = [
    {
      name        = "${local.name}-user"
      description = "Developer user"
      email       = "user@example.com"
      enabled     = true
      access_type = "programmatic"
    }
  ]

  groups = [
    {
      name        = "${local.name}-developers"
      description = "Developer group"
    }
  ]

  group_memberships = [
    {
      group_name = "${local.name}-developers"
      user_names = ["${local.name}-user"]
    }
  ]

  group_role_assignments = [
    {
      group_name = "${local.name}-developers"
      role_id    = data.huaweicloud_identity_role.rds_readonly.id
      project_id = "all"
    }
  ]
}
