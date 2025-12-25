# Compute Module Outputs
output "amd_machine_instances" {
  description = "List of AMD machine instance information"
  value = [
    for idx, instance in oci_core_instance.amd_machine :
    {
      id             = instance.id
      display_name   = instance.display_name
      private_ip     = instance.private_ip
      public_ip      = instance.public_ip
      shape          = instance.shape
      state          = instance.state
      boot_volume_id = instance.boot_volume_id
    }
  ]
}

output "arm_machine_instance" {
  description = "ARM machine instance information"
  value = var.arm_instance_enabled ? {
    id             = oci_core_instance.arm_machine[0].id
    display_name   = oci_core_instance.arm_machine[0].display_name
    private_ip     = oci_core_instance.arm_machine[0].private_ip
    public_ip      = oci_core_instance.arm_machine[0].public_ip
    shape          = oci_core_instance.arm_machine[0].shape
    state          = oci_core_instance.arm_machine[0].state
    boot_volume_id = oci_core_instance.arm_machine[0].boot_volume_id
  } : null
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = var.ssh_private_key_path
}

output "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  value       = var.ssh_public_key_path
}

output "ssh_connection_info" {
  description = "SSH connection information for all instances"
  value = {
    amd_machine_instances = [
      for idx, instance in oci_core_instance.amd_machine :
      {
        host     = instance.public_ip
        user     = "ubuntu"
        key_path = var.ssh_private_key_path
        hostname = instance.display_name
      }
    ]
    arm_machine_instance = var.arm_instance_enabled ? {
      host     = oci_core_instance.arm_machine[0].public_ip
      user     = "ubuntu"
      key_path = var.ssh_private_key_path
      hostname = oci_core_instance.arm_machine[0].display_name
    } : null
  }
}