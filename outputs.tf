################################################################################
# IAM Users
################################################################################

output "user_ids" {
  description = "Map of user IDs, keyed by user name"
  value = {
    for name, user in huaweicloud_identity_user.this : name => user.id
  }
}

output "users" {
  description = "Map of user details, keyed by user name"
  value = {
    for name, user in huaweicloud_identity_user.this : name => {
      id                                = user.id
      name                              = user.name
      description                       = user.description
      email                             = user.email
      phone                             = user.phone
      country_code                      = user.country_code
      enabled                           = user.enabled
      access_type                       = user.access_type
      password_strength                 = user.password_strength
      create_time                       = user.create_time
      last_login                        = user.last_login
      external_identity_id              = user.external_identity_id
      external_identity_type            = user.external_identity_type
      login_protect_verification_method = user.login_protect_verification_method
    }
  }
}

output "user_names" {
  description = "List of user names"
  value       = [for name, user in huaweicloud_identity_user.this : name]
}

################################################################################
# IAM Groups
################################################################################

output "group_ids" {
  description = "Map of group IDs, keyed by group name"
  value = {
    for name, group in huaweicloud_identity_group.this : name => group.id
  }
}

output "groups" {
  description = "Map of group details, keyed by group name"
  value = {
    for name, group in huaweicloud_identity_group.this : name => {
      id          = group.id
      name        = group.name
      description = group.description
    }
  }
}

output "group_names" {
  description = "List of group names"
  value       = [for name, group in huaweicloud_identity_group.this : name]
}

################################################################################
# Group Memberships
################################################################################

output "group_memberships" {
  description = "Map of group membership details, keyed by group name"
  value = {
    for group_name, membership in huaweicloud_identity_group_membership.this : group_name => {
      id       = membership.id
      group_id = membership.group
      user_ids = membership.users
      user_names = [
        for user_id in membership.users : [
          for name, user in huaweicloud_identity_user.this : name
          if user.id == user_id
        ][0]
      ]
    }
  }
}

output "group_membership_ids" {
  description = "Map of group membership IDs, keyed by group name"
  value = {
    for group_name, membership in huaweicloud_identity_group_membership.this : group_name => membership.id
  }
}

output "group_role_assignments" {
  description = "Map of group role assignment details"
  value = {
    for key, assignment in huaweicloud_identity_group_role_assignment.this : key => {
      id       = assignment.id
      group_id = assignment.group_id
      group_name = [
        for name, group in huaweicloud_identity_group.this : name
        if group.id == assignment.group_id
      ][0]
      role_id               = assignment.role_id
      domain_id             = assignment.domain_id
      project_id            = assignment.project_id
      enterprise_project_id = assignment.enterprise_project_id
    }
  }
}

output "group_role_assignment_ids" {
  description = "Map of group role assignment IDs"
  value = {
    for key, assignment in huaweicloud_identity_group_role_assignment.this : key => assignment.id
  }
}
