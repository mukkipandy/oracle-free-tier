# Backup Module
# This module creates volume backup policies and assignments

resource "oci_core_volume_backup_policy" "daily" {
  compartment_id = var.compartment_id

  display_name = "Daily Backup Policy"

  schedules {
    backup_type       = "INCREMENTAL"
    hour_of_day       = var.hour_of_day
    offset_type       = "STRUCTURED"
    period            = "ONE_DAY"
    retention_seconds = var.retention_seconds
    time_zone         = "REGIONAL_DATA_CENTER_TIME"
  }
}

resource "oci_core_volume_backup_policy_assignment" "this" {
  count = length(var.boot_volume_ids)

  asset_id  = var.boot_volume_ids[count.index]
  policy_id = oci_core_volume_backup_policy.daily.id
}