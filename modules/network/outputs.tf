# Network Module Outputs
output "compartment_id" {
  description = "ID of the created compartment"
  value       = oci_identity_compartment.this.id
}

output "vcn_id" {
  description = "ID of the created VCN"
  value       = oci_core_vcn.this.id
}

output "vcn_cidr_block" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.this.cidr_blocks.0
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = oci_core_subnet.this.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = oci_core_internet_gateway.this.id
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = oci_core_network_security_group.this.id
}