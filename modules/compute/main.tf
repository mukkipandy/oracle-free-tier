# Compute Module
# This module creates compute instances using SSH keys from the SSH module

# Get availability domains
data "oci_identity_availability_domains" "this" {
  compartment_id = var.tenancy_ocid
}

# Randomly select availability domain
resource "random_shuffle" "this" {
  input        = data.oci_identity_availability_domains.this.availability_domains[*].name
  result_count = 1
}

# Get available shapes for each availability domain
data "oci_core_shapes" "this" {
  for_each = toset(data.oci_identity_availability_domains.this.availability_domains[*].name)

  compartment_id = var.compartment_id

  availability_domain = each.key
}

# Cloud-init configuration for instances
data "cloudinit_config" "ubuntu_linux" {
  part {
    content = yamlencode({
      runcmd = ["apt-get remove --quiet --assume-yes --purge apparmor"]
    })
    content_type = "text/cloud-config"
  }
}

data "cloudinit_config" "oracle_linux" {
  part {
    content = yamlencode({
      runcmd = ["grubby --args selinux=0 --update-kernel ALL"]
    })
    content_type = "text/cloud-config"
  }
}

# Get latest Ubuntu images
data "oci_core_images" "amd_machine" {
  compartment_id   = var.compartment_id
  operating_system = "Canonical Ubuntu"
  shape            = local.instance.amd_machine.shape
  sort_by          = "DISPLAYNAME"
  sort_order       = "DESC"
  state            = "AVAILABLE"
}

# Get latest Oracle Linux images
data "oci_core_images" "arm_machine" {
  compartment_id   = var.compartment_id
  operating_system = "Canonical Ubuntu"
  shape            = local.instance.arm_machine.shape
  sort_by          = "DISPLAYNAME"
  sort_order       = "DESC"
  state            = "AVAILABLE"
}

# Create amd_machine instances
resource "oci_core_instance" "amd_machine" {
  count = var.amd_compute_instance_count

  availability_domain = one(
    [
      for m in data.oci_core_shapes.this :
      m.availability_domain
      if contains(m.shapes[*].name, local.instance.amd_machine.shape)
    ]
  )
  compartment_id = var.compartment_id
  shape          = local.instance.amd_machine.shape

  display_name         = "AMD Machine ${count.index + 1}"
  preserve_boot_volume = false

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.ubuntu_linux.rendered
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  create_vnic_details {
    display_name   = "AMD Machine ${count.index + 1}"
    hostname_label = "amd-machine-${count.index + 1}"
    nsg_ids        = [var.network_security_group_id]
    subnet_id      = var.subnet_id
  }

  source_details {
    source_id               = data.oci_core_images.amd_machine.images.0.id
    source_type             = "image"
    boot_volume_size_in_gbs = 50
  }

  lifecycle {
    ignore_changes = [source_details.0.source_id]
  }
}

# Create arm_machine instance (conditional)
resource "oci_core_instance" "arm_machine" {
  count               = var.arm_instance_enabled ? 1 : 0
  availability_domain = random_shuffle.this.result.0
  compartment_id      = var.compartment_id
  shape               = local.instance.arm_machine.shape

  display_name         = "ARM Machine"
  preserve_boot_volume = false

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.ubuntu_linux.rendered
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  create_vnic_details {
    assign_public_ip = false
    display_name     = "ARM Machine"
    hostname_label   = "arm-machine"
    nsg_ids          = [var.network_security_group_id]
    subnet_id        = var.subnet_id
  }

  shape_config {
    memory_in_gbs = 24
    ocpus         = 4
  }

  source_details {
    source_id               = data.oci_core_images.arm_machine.images.0.id
    source_type             = "image"
    boot_volume_size_in_gbs = 100
  }

  lifecycle {
    ignore_changes = [source_details.0.source_id]
  }
}

# Get private IP for arm_machine instance (only if enabled)
data "oci_core_private_ips" "arm_machine" {
  count      = var.arm_instance_enabled ? 1 : 0
  ip_address = oci_core_instance.arm_machine[0].private_ip
  subnet_id  = var.subnet_id
}

# Create reserved public IP for arm_machine instance (only if enabled)
resource "oci_core_public_ip" "arm_machine" {
  count = var.arm_instance_enabled ? 1 : 0

  compartment_id = var.compartment_id
  lifetime       = "RESERVED"

  display_name  = oci_core_instance.arm_machine[0].display_name
  private_ip_id = data.oci_core_private_ips.arm_machine[0].private_ips.0.id
}

locals {
  instance = {
    amd_machine = {
      shape : "VM.Standard.E2.1.Micro",
      #operating_system = "Canonical Ubuntu",
    },
    arm_machine = {
      shape : "VM.Standard.A1.Flex",
      #operating_system = "Oracle Linux",
    },
  }
}