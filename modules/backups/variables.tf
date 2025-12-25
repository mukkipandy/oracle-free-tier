# Backup Module Variables
variable "compartment_id" {
  description = "ID of the compartment"
  type        = string
  nullable    = false
}

variable "boot_volume_ids" {
  description = "List of boot volume IDs to assign backup policy to"
  type        = list(string)
  default     = []
}

variable "hour_of_day" {
  description = "Hour of the day to run backups (0-23)"
  type        = number
  default     = 0
}

variable "retention_seconds" {
  description = "Retention period in seconds (86400 = 1 day)"
  type        = number
  default     = 86400 # 1 day retention for free tier
}