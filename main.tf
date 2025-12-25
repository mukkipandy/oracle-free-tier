# Main Terraform Configuration
# This is the orchestrator that calls all modules

# Provider configuration is in terraform.tf file

# Call SSH Module first (generates keys)
module "ssh" {
  source = "./modules/ssh"

  key_save_path = var.key_save_path
  key_name      = "oci_compute"
}

# Call Network Module
module "network" {
  source = "./modules/network"

  tenancy_ocid     = var.tenancy_ocid
  compartment_name = var.compartment_name
  cidr_block       = var.cidr_block
  ssh_source_ip    = var.ssh_source_ip
}

# Call Compute Module (uses SSH keys from SSH module)
module "compute" {
  source = "./modules/compute"

  tenancy_ocid               = var.tenancy_ocid
  compartment_id             = module.network.compartment_id
  subnet_id                  = module.network.subnet_id
  network_security_group_id  = module.network.network_security_group_id
  ssh_public_key             = module.ssh.public_key_openssh
  ssh_private_key_path       = module.ssh.private_key_path
  ssh_public_key_path        = module.ssh.public_key_path
  amd_compute_instance_count = var.amd_compute_instance_count
  arm_instance_enabled       = var.arm_instance_enabled
}

# Call Backup Module
module "backups" {
  source = "./modules/backups"

  compartment_id = module.network.compartment_id
  boot_volume_ids = concat(
    module.compute.amd_machine_instances[*].boot_volume_id,
    module.compute.arm_machine_instance != null ? [module.compute.arm_machine_instance.boot_volume_id] : []
  )
}

# Output summary information
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    compartment_name      = var.compartment_name
    region                = var.region
    vcn_cidr              = module.network.vcn_cidr_block
    amd_machine_instances = length(module.compute.amd_machine_instances)
    arm_machine_instance  = module.compute.arm_machine_instance != null ? 1 : 0
    backup_policy_name    = module.backups.backup_policy_name
  }
}

output "ssh_connection_instructions" {
  description = "Instructions for connecting to instances via SSH"
  value = {
    private_key_location = module.compute.ssh_private_key_path
    amd_machine_instances = [
      for instance in module.compute.amd_machine_instances :
      "ssh -i ${module.compute.ssh_private_key_path} ubuntu@${instance.public_ip}  # ${instance.display_name}"
    ]
    arm_machine_instance = module.compute.arm_machine_instance != null ? "ssh -i ${module.compute.ssh_private_key_path} ubuntu@${module.compute.arm_machine_instance.public_ip}  # ${module.compute.arm_machine_instance.display_name}" : null
  }
}
