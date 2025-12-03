################################################################################
# IAM Users
################################################################################

variable "users" {
  description = <<-EOF
    List of IAM users to create. Each user can have the following attributes:
    - name (required): User name (1-32 characters, can contain uppercase letters, lowercase letters, digits, spaces, and special characters (-_))
    - description (optional): User description
    - email (optional): Email address (max 255 characters)
    - phone (optional): Mobile number (max 32 digits, must be used together with country_code)
    - country_code (optional): Country code (e.g., "0086" for Chinese mainland, must be used together with phone)
    - password (optional): Password (6-32 characters, must contain at least two of: uppercase, lowercase, digits, special chars)
    - pwd_reset (optional): Whether password should be reset at first login (default: true)
    - enabled (optional): Whether user is enabled (default: true)
    - access_type (optional): Access type - "default" (both programmatic and console), "programmatic", or "console" (default: "default")
    - external_identity_id (optional): ID of IAM user in external system (for SSO)
    - external_identity_type (optional): Type of IAM user in external system (only "TenantIdp" supported, must be used with external_identity_id)
    - login_protect_verification_method (optional): Login protection verification method - "sms", "email", or "vmfa" (empty disables login protection)
  EOF
  type = list(object({
    name                              = string
    description                       = optional(string)
    email                             = optional(string)
    phone                             = optional(string)
    country_code                      = optional(string)
    password                          = optional(string, null)
    pwd_reset                         = optional(bool)
    enabled                           = optional(bool, true)
    access_type                       = optional(string, "default")
    external_identity_id              = optional(string)
    external_identity_type            = optional(string)
    login_protect_verification_method = optional(string)
  }))
  default = []
}

################################################################################
# IAM Groups
################################################################################

variable "groups" {
  description = <<-EOF
    List of IAM groups to create. Each group can have the following attributes:
    - name (required): Group name (length <= 64 bytes)
    - description (optional): Group description
  EOF
  type = list(object({
    name        = string
    description = optional(string)
  }))
  default = []
}

################################################################################
# Group Memberships
################################################################################

variable "group_memberships" {
  description = <<-EOF
    List of group memberships to create. Each membership defines which users belong to which group.
    - group_name (required): Name of the group (must exist in groups variable)
    - user_names (required): List of user names to add to the group (users must exist in users variable)
  EOF
  type = list(object({
    group_name = string
    user_names = list(string)
  }))
  default = []
}

variable "group_role_assignments" {
  description = <<-EOF
    List of role assignments for groups. Each assignment assigns a role to a group.

    - group_name (required): Name of the group (must exist in groups variable)
    - role_id (required): ID of the role to assign
    - domain_id (optional): Domain ID to assign the role in
    - project_id (optional): Project ID to assign the role in (use "all" for all projects)
    - enterprise_project_id (optional): Enterprise project ID to assign the role in
  EOF
  type = list(object({
    group_name            = string
    role_id               = string
    domain_id             = optional(string)
    project_id            = optional(string)
    enterprise_project_id = optional(string)
  }))
  default = []
}
