provider "huaweicloud" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "tr-west-1"
}

################################################################################
# IAM Module
################################################################################

module "iam" {
  source = "../../"

  managed_role_names = [
    "RDS ReadOnlyAccess",
    "OBS ReadOnlyAccess",
  ]

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

  # role_id can be a display name (auto-resolved) or an actual role ID
  group_role_assignments = [
    {
      group_name = "${local.name}-developers"
      role_id    = "RDS ReadOnlyAccess" # Using display name - auto-resolved to ID
      project_id = "all"
    }
  ]
}
