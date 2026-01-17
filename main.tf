################################################################################
# Managed Roles (Data Source)
################################################################################

data "huaweicloud_identity_role" "managed" {
  for_each     = toset(var.managed_role_names)
  display_name = each.value
}

locals {
  managed_role_id_map = {
    for name, role in data.huaweicloud_identity_role.managed : name => role.id
  }
}

################################################################################
# IAM Users
################################################################################

resource "huaweicloud_identity_user" "this" {
  for_each = { for user in var.users : user.name => user }

  name                              = each.value.name
  description                       = try(each.value.description, null)
  email                             = try(each.value.email, null)
  phone                             = try(each.value.phone, null)
  country_code                      = try(each.value.country_code, null)
  password                          = try(each.value.password, null)
  pwd_reset                         = try(each.value.pwd_reset, null)
  enabled                           = try(each.value.enabled, true)
  access_type                       = try(each.value.access_type, "default")
  external_identity_id              = try(each.value.external_identity_id, null)
  external_identity_type            = try(each.value.external_identity_type, null)
  login_protect_verification_method = try(each.value.login_protect_verification_method, null)
}

################################################################################
# IAM Groups
################################################################################

resource "huaweicloud_identity_group" "this" {
  for_each = { for group in var.groups : group.name => group }

  name        = each.value.name
  description = try(each.value.description, null)
}

################################################################################
# Group Memberships
################################################################################

resource "huaweicloud_identity_group_membership" "this" {
  for_each = {
    for membership in var.group_memberships : membership.group_name => membership
  }

  group = huaweicloud_identity_group.this[each.value.group_name].id
  users = [
    for user_name in each.value.user_names : huaweicloud_identity_user.this[user_name].id
  ]

  depends_on = [
    huaweicloud_identity_group.this,
    huaweicloud_identity_user.this
  ]
}

resource "huaweicloud_identity_group_role_assignment" "this" {
  for_each = {
    for assignment in var.group_role_assignments : "${assignment.group_name}/${assignment.role_id}/${coalesce(assignment.domain_id, assignment.project_id, assignment.enterprise_project_id, "unknown")}" => assignment
  }

  group_id = huaweicloud_identity_group.this[each.value.group_name].id

  role_id = lookup(local.managed_role_id_map, each.value.role_id, each.value.role_id)

  domain_id             = try(each.value.domain_id, null)
  project_id            = try(each.value.project_id, null)
  enterprise_project_id = try(each.value.enterprise_project_id, null)

  depends_on = [
    huaweicloud_identity_group.this,
    data.huaweicloud_identity_role.managed
  ]
}

################################################################################
# IAM Agencies
################################################################################

resource "huaweicloud_identity_agency" "this" {
  for_each = { for agency in var.agencies : agency.name => agency }

  name                  = each.value.name
  description           = try(each.value.description, null)
  delegated_domain_name = each.value.delegated_domain_name
  duration              = try(each.value.duration, "FOREVER")

  dynamic "project_role" {
    for_each = try(each.value.project_roles, [])
    content {
      project = project_role.value.project
      roles   = project_role.value.roles
    }
  }

  domain_roles        = try(each.value.domain_roles, [])
  all_resources_roles = try(each.value.all_resources_roles, [])

  dynamic "enterprise_project_roles" {
    for_each = try(each.value.enterprise_project_roles, [])
    content {
      enterprise_project = enterprise_project_roles.value.enterprise_project
      roles              = enterprise_project_roles.value.roles
    }
  }
}
