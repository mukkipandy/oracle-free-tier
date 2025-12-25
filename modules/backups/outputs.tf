# Backup Module Outputs
output "backup_policy_id" {
  description = "ID of the created backup policy"
  value       = oci_core_volume_backup_policy.daily.id
}

output "backup_policy_name" {
  description = "Name of the backup policy"
  value       = oci_core_volume_backup_policy.daily.display_name
}

output "backup_assignments" {
  description = "List of backup policy assignments"
  value = [
    for idx, assignment in oci_core_volume_backup_policy_assignment.this :
    {
      assignment_id = assignment.id
      asset_id      = assignment.asset_id
      policy_id     = assignment.policy_id
    }
  ]
}