# HuaweiCloud IAM Terraform Module

Terraform module which creates IAM (Identity and Access Management) users, groups, group memberships, role assignments, and agencies on HuaweiCloud.

## Features

This module supports the following IAM features:

- ✅ **IAM Users**: Create and manage IAM users with comprehensive configuration options
- ✅ **IAM Groups**: Create and manage IAM user groups
- ✅ **Group Memberships**: Assign users to groups
- ✅ **User Role Assignments**: Assign roles to users within enterprise projects
- ✅ **Group Role Assignments**: Assign roles to groups at domain, project, or enterprise project level
- ✅ **IAM Agencies**: Create and manage cross-service agencies for delegated access
- ✅ **User Access Types**: Support for programmatic, console, or both access types
- ✅ **Login Protection**: Support for SMS, email, or MFA login protection
- ✅ **External Identity**: Support for external identity providers (SSO)
- ✅ **Managed Roles Lookup**: Automatic role ID lookup by display name (Terragrunt-friendly)

## Examples

- [simple](./examples/simple) - Basic example with users, groups, memberships, and role assignments

## Usage

### Basic Example

```hcl
module "iam" {
  source = "github.com/artifactsystems/terraform-huawei-iam?ref=v1.1.0"

  # Managed roles - automatic ID lookup by display name
  managed_role_names = [
    "RDS ReadOnlyAccess",
    "OBS ReadOnlyAccess",
  ]

  users = [
    {
      name        = "john.doe"
      description = "John Doe user"
      email       = "john.doe@example.com"
      enabled     = true
      access_type = "default"
    }
  ]

  groups = [
    {
      name        = "developers"
      description = "Developer group"
    }
  ]

  group_memberships = [
    {
      group_name = "developers"
      user_names = ["john.doe"]
    }
  ]

  # role_id supports both display names (auto-resolved) and actual role IDs
  group_role_assignments = [
    {
      group_name = "developers"
      role_id    = "RDS ReadOnlyAccess"  # Display name - auto-resolved to ID
      project_id = "all"
    }
  ]
}
```

### Advanced Example with Role Assignments

```hcl
data "huaweicloud_identity_role" "obs_admin" {
  name = "obs_adm"
}

data "huaweicloud_identity_role" "rds_admin" {
  name = "rds_adm"
}

module "iam" {
  source = "github.com/artifactsystems/terraform-huawei-iam?ref=v1.0.0"

  users = [
    {
      name        = "developer1"
      description = "Developer user"
      email       = "dev1@example.com"
      enabled     = true
      access_type = "programmatic"
    },
    {
      name        = "admin1"
      description = "Administrator user"
      email       = "admin1@example.com"
      phone       = "13800138000"
      country_code = "0086"
      enabled     = true
      access_type = "default"
      login_protect_verification_method = "sms"
    }
  ]

  groups = [
    {
      name        = "developers"
      description = "Developer group"
    },
    {
      name        = "admins"
      description = "Administrator group"
    }
  ]

  group_memberships = [
    {
      group_name = "developers"
      user_names = ["developer1"]
    },
    {
      group_name = "admins"
      user_names = ["admin1"]
    }
  ]

  # Assign role to group at project level (all projects)
  group_role_assignments = [
    {
      group_name = "developers"
      role_id    = data.huaweicloud_identity_role.rds_admin.id
      project_id = "all"
    }
  ]

}
```

### User with External Identity (SSO)

```hcl
module "iam" {
  source = "github.com/artifactsystems/terraform-huawei-iam?ref=v1.0.0"

  users = [
    {
      name                  = "sso-user"
      description           = "SSO user"
      enabled               = true
      external_identity_id = "external-user-id-123"
      external_identity_type = "TenantIdp"
    }
  ]
}
```

### Agency Example for Cross-Service Access

```hcl
module "iam" {
  source = "github.com/artifactsystems/terraform-huawei-iam?ref=v1.0.0"

  agencies = [
    {
      name                  = "css-log-agency"
      description           = "Agency for CSS to access OBS for log storage"
      delegated_domain_name = "op_svc_css"

      # Grant OBS access permissions
      all_resources_roles = [
        "OBS OperateAccess"
      ]
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| huaweicloud | >= 1.79.0 |

## Providers

| Name | Version |
|------|---------|
| huaweicloud | >= 1.79.0 |

## Resources

| Name | Type |
|------|------|
| [huaweicloud_identity_user](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/identity_user) | resource |
| [huaweicloud_identity_group](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/identity_group) | resource |
| [huaweicloud_identity_group_membership](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/identity_group_membership) | resource |
| [huaweicloud_identity_user_role_assignment](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/identity_user_role_assignment) | resource |
| [huaweicloud_identity_group_role_assignment](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/identity_group_role_assignment) | resource |
| [huaweicloud_identity_agency](https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/identity_agency) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| managed_role_names | List of Huawei Cloud managed role display names to look up | `list(string)` | `[]` | no |
| users | List of IAM users to create | `list(object)` | `[]` | no |
| groups | List of IAM groups to create | `list(object)` | `[]` | no |
| group_memberships | List of group memberships to create | `list(object)` | `[]` | no |
| user_role_assignments | List of enterprise-project role assignments for users | `list(object)` | `[]` | no |
| group_role_assignments | List of role assignments for groups | `list(object)` | `[]` | no |
| agencies | List of IAM agencies to create | `list(object)` | `[]` | no |

### users Object

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | User name (1-32 characters) | `string` | n/a | yes |
| description | User description | `string` | `null` | no |
| email | Email address (max 255 characters) | `string` | `null` | no |
| phone | Mobile number (max 32 digits, must be used with country_code) | `string` | `null` | no |
| country_code | Country code (e.g., "0086" for Chinese mainland) | `string` | `null` | no |
| password | Password (6-32 characters, must contain at least two of: uppercase, lowercase, digits, special chars) | `string` | `null` | no |
| pwd_reset | Whether password should be reset at first login | `bool` | `null` | no |
| enabled | Whether user is enabled | `bool` | `true` | no |
| access_type | Access type: "default", "programmatic", or "console" | `string` | `"default"` | no |
| external_identity_id | ID of IAM user in external system (for SSO) | `string` | `null` | no |
| external_identity_type | Type of IAM user in external system (only "TenantIdp" supported) | `string` | `null` | no |
| login_protect_verification_method | Login protection method: "sms", "email", or "vmfa" | `string` | `null` | no |

### groups Object

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Group name (length <= 64 bytes) | `string` | n/a | yes |
| description | Group description | `string` | `null` | no |

### group_memberships Object

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| group_name | Name of the group (must exist in groups variable) | `string` | n/a | yes |
| user_names | List of user names to add to the group | `list(string)` | n/a | yes |

### group_role_assignments Object

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| group_name | Name of the group (must exist in groups variable) | `string` | n/a | yes |
| role_id | ID of the role to assign | `string` | n/a | yes |
| domain_id | Domain ID to assign the role in | `string` | `null` | no |
| project_id | Project ID to assign the role in (use "all" for all projects) | `string` | `null` | no |
| enterprise_project_id | Enterprise project ID to assign the role in | `string` | `null` | no |

**Note:** Exactly one of `domain_id`, `project_id`, or `enterprise_project_id` must be specified.

### agencies Object

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Agency name (1-64 characters) | `string` | n/a | yes |
| description | Agency description (0-255 characters, excluding '@#$%^&*<>\') | `string` | `null` | no |
| delegated_domain_name | Name of delegated user domain (e.g., "op_svc_css" for CSS) | `string` | n/a | yes |
| duration | Validity period: "FOREVER", "ONEDAY", or specific days | `string` | `"FOREVER"` | no |
| project_roles | List of roles and projects for project-level permissions | `list(object)` | `[]` | no |
| domain_roles | List of role names for domain-level permissions | `list(string)` | `[]` | no |
| all_resources_roles | List of role names for permissions on all resources | `list(string)` | `[]` | no |
| enterprise_project_roles | List of roles and enterprise projects | `list(object)` | `[]` | no |

**Note:** At least one of `project_roles`, `domain_roles`, `all_resources_roles` or `enterprise_project_roles` must be specified.

## Outputs

| Name | Description |
|------|-------------|
| managed_role_ids | Map of managed role IDs, keyed by display name |
| managed_roles | Map of managed role details, keyed by display name |
| user_ids | Map of user IDs, keyed by user name |
| users | Map of user details, keyed by user name |
| user_names | List of user names |
| group_ids | Map of group IDs, keyed by group name |
| groups | Map of group details, keyed by group name |
| group_names | List of group names |
| group_memberships | Map of group membership details, keyed by group name |
| group_membership_ids | Map of group membership IDs, keyed by group name |
| group_role_assignments | Map of group role assignment details |
| group_role_assignment_ids | Map of group role assignment IDs |
| agency_ids | Map of agency IDs, keyed by agency name |
| agencies | Map of agency details, keyed by agency name |
| agency_names | List of agency names |

## Notes

- You must have admin privileges to use this module
- When role assignments are created, permissions will take effect after 15 to 30 minutes
- Password cannot be imported due to security reasons. Use `lifecycle { ignore_changes = [password] }` if importing existing users
- User names must be unique and consist of 1 to 32 characters (uppercase letters, lowercase letters, digits, spaces, and special characters (-_))
- Group names must be unique and have a length less than or equal to 64 bytes

## Contributing

Report issues/questions/feature requests in the [issues](https://github.com/artifactsystems/terraform-huawei-iam/issues/new) section.

Full contributing [guidelines are covered here](.github/CONTRIBUTING.md).
