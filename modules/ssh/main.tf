# SSH Key Management Module
# This module handles SSH key generation and local file storage

# Generate SSH keypair for instances
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

# Create keys directory (cross-platform approach)
resource "null_resource" "create_keys_dir" {
  provisioner "local-exec" {
    command     = "if \"%OS%\"==\"Windows_NT\" (${replace(path.module, "/", "\\")}\\create_keys_directory.bat ${var.key_save_path}) else (${path.module}/create_keys_directory.sh ${var.key_save_path})"
    interpreter = ["cmd", "/C"]
  }

}



# Save private key to local file
resource "local_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${var.key_save_path}/${var.key_name}_private_key"
  file_permission = "0400"

  depends_on = [null_resource.create_keys_dir]
}

# Save public key to local file
resource "local_file" "public_key" {
  content         = tls_private_key.this.public_key_openssh
  filename        = "${var.key_save_path}/${var.key_name}_public_key.pub"
  file_permission = "0400"

  depends_on = [null_resource.create_keys_dir]
}