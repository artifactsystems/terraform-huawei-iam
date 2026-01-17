output "custom_policy_ids" {
  description = "Custom policy IDs"
  value       = module.iam.custom_policy_ids
}

output "custom_policies" {
  description = "Custom policy details"
  value       = module.iam.custom_policies
}

output "group_ids" {
  description = "Group IDs"
  value       = module.iam.group_ids
}

output "group_role_assignments" {
  description = "Group role assignments"
  value       = module.iam.group_role_assignments
}
