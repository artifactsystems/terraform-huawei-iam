output "user_ids" {
  description = "User IDs"
  value       = module.iam.user_ids
}

output "group_ids" {
  description = "Group IDs"
  value       = module.iam.group_ids
}

output "group_memberships" {
  description = "Group membership details"
  value       = module.iam.group_memberships
}

output "group_role_assignments" {
  description = "Group role assignments"
  value       = module.iam.group_role_assignments
}

output "managed_role_ids" {
  description = "Map of managed role IDs for reference"
  value       = module.iam.managed_role_ids
}
