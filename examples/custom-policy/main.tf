provider "huaweicloud" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "tr-west-1"
}

################################################################################
# IAM Module with Custom Policies
################################################################################

module "iam" {
  source = "../../"

  # Custom policies - create your own IAM policies
  custom_policies = [
    {
      name        = "${local.name}-obs-readonly"
      description = "Custom OBS read-only policy for specific buckets"
      type        = "AX" # Global service project
      policy = jsonencode({
        Version = "1.1"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "obs:bucket:GetBucketAcl",
              "obs:bucket:ListBucket",
              "obs:object:GetObject"
            ]
            Resource = [
              "obs:*:*:bucket:*",
              "obs:*:*:object:*"
            ]
          }
        ]
      })
    }
  ]

  groups = [
    {
      name        = "${local.name}-developers"
      description = "Developer group with custom policy"
    }
  ]

  group_role_assignments = [
    {
      group_name = "${local.name}-developers"
      role_id    = "${local.name}-obs-readonly"
      project_id = "all"
    }
  ]
}
