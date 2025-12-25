# Compute Module Variables
variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
  nullable    = false
}

variable "compartment_id" {
  description = "ID of the compartment to create instances in"
  type        = string
  nullable    = false
}

variable "subnet_id" {
  description = "ID of the subnet to attach instances to"
  type        = string
  nullable    = false
}

variable "network_security_group_id" {
  description = "ID of the network security group"
  type        = string
  nullable    = false
}

variable "ssh_public_key" {
  description = "SSH public key to use for instance access"
  type        = string
  nullable    = false
}

variable "amd_compute_instance_count" {
  description = "Number of amd instances to create"
  type        = number
  nullable    = false
}

variable "arm_instance_enabled" {
  description = "Whether to create arm instance"
  type        = bool
  nullable    = false
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file (from SSH module)"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file (from SSH module)"
  type        = string
}