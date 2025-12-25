# SSH Module Outputs
output "private_key_pem" {
  description = "Private key in PEM format"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}

output "public_key_openssh" {
  description = "Public key in OpenSSH format"
  value       = tls_private_key.this.public_key_openssh
}

output "private_key_path" {
  description = "Path to the generated SSH private key file"
  value       = "${var.key_save_path}/${var.key_name}_private_key"
}

output "public_key_path" {
  description = "Path to the generated SSH public key file"
  value       = "${var.key_save_path}/${var.key_name}_public_key.pub"
}

output "key_fingerprints" {
  description = "Key fingerprints for verification"
  value = {
    sha256 = tls_private_key.this.public_key_fingerprint_sha256
  }
}