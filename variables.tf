# Main Variables
# These variables configure the OCI deployment

variable "tenancy_ocid" {
  description = "OCID of the tenancy. Can be found in OCI Console > Administration > Tenancy Details"
  type        = string
  nullable    = false
}

variable "user_ocid" {
  description = "OCID of the user. Can be found in OCI Console > Identity > Users"
  type        = string
  nullable    = false
}

variable "region" {
  description = "Region for resources (e.g., us-phoenix-1, us-ashburn-1). Will use OCI CLI region if not specified"
  type        = string
  nullable    = false
  default     = "ap-mumbai-1"
}

variable "compartment_name" {
  description = "Name of the compartment to create"
  type        = string
  default     = "OCI-Free-Compute-Maximal"
}

variable "cidr_block" {
  description = "CIDR block of the VCN. If null, a random CIDR will be generated"
  type        = string
  default     = null

  validation {
    condition = (
      var.cidr_block == null ?
      true :
      alltrue(
        [
          can(cidrsubnet(var.cidr_block, 2, 0)),
          cidrhost(var.cidr_block, 0) == split("/", var.cidr_block).0,
        ]
      )
    )
    error_message = "The value of cidr_block variable must be a valid CIDR address with a prefix no greater than 30."
  }
}

variable "ssh_source_ip" {
  description = "Source IP address for SSH access (format: IP/CIDR). Use your current public IP"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_save_path" {
  description = "Path to save generated SSH keys"
  type        = string
  default     = "keys"
}

variable "amd_compute_instance_count" {
  description = "Number of AMD instances to create (max 2 on free tier)"
  type        = number
  default     = 2

  validation {
    condition     = var.amd_compute_instance_count >= 0 && var.amd_compute_instance_count <= 2
    error_message = "AMD instance count must be between 0 and 2 for free tier."
  }
}

variable "arm_instance_enabled" {
  description = "Whether to create ARM instance"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups (free tier allows max 1 day due to backup limit)"
  type        = number
  default     = 1

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 7
    error_message = "Backup retention days must be between 1 and 7."
  }
}
