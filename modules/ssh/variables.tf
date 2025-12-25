# SSH Module Variables
variable "key_save_path" {
  description = "Path to save generated SSH keys"
  type        = string
  default     = "keys"
}

variable "key_name" {
  description = "Base name for SSH key files (without extension)"
  type        = string
  default     = "oci_compute"
}

variable "rsa_bits" {
  description = "Number of bits for RSA key generation"
  type        = number
  default     = 4096
}