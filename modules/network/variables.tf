# Network Module Variables
variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
  nullable    = false
}

variable "compartment_name" {
  description = "Name of the compartment to create"
  type        = string
  default     = "OCI-Free-Compute-Maximal"
}

variable "compartment_description" {
  description = "Description for the compartment"
  type        = string
  default     = "Compartment for OCI Free Tier compute resources"
}

variable "vcn_display_name" {
  description = "Display name for VCN"
  type        = string
  default     = "OCI-Free-Compute-VCN"
}

variable "subnet_display_name" {
  description = "Display name for subnet"
  type        = string
  default     = "OCI-Free-Compute-Subnet"
}

variable "nsg_display_name" {
  description = "Display name for network security group"
  type        = string
  default     = "OCI-Free-Compute-NSG"
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
  description = "Source IP address for SSH access (format: IP/CIDR)"
  type        = string
  nullable    = false
}

variable "allowed_ports" {
  description = "List of ports to allow in security rules"
  type        = list(number)
  default     = [22]
}