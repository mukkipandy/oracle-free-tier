# Oracle Cloud Infrastructure Free Tier Terraform Project

## 🚀 Overview

This Terraform project deploys maximum free tier resources on Oracle Cloud Infrastructure (OCI), providing a complete infrastructure setup with compute instances, networking, and automated backups. The project is designed to maximize the free tier allowances while maintaining security best practices.

### Free Tier Resources Deployed

- **Compute Instances**: Up to 2 AMD instances (VM.Standard.E2.1.Micro) + 1 ARM instance (VM.Standard.A1.Flex)
- **Networking**: Virtual Cloud Network (VCN) with public subnet
- **Storage**: Boot volumes (50GB for AMD, 100GB for ARM)
- **Backups**: Automated volume backup policies
- **SSH Keys**: Generated automatically for secure access

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OCI Free Tier Architecture               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │   Compartment   │    │        VCN (192.168.x.0/24)     │ │
│  │                 │    │                                 │ │
│  │ OCI-Free-       │    │  ┌───────────────────────────┐  │ │
│  │ Compute-        │    │  │      Public Subnet        │  │ │
│  │ Maximal         │    │  │                           │  │ │
│  └─────────────────┘    │  │  ┌─────┐  ┌─────┐  ┌─────┐ │  │ │
│                         │  │  │ AMD │  │ AMD │  │ ARM │ │  │ │
│                         │  │  │ VM  │  │ VM  │  │ VM  │ │  │ │
│                         │  │  └─────┘  └─────┘  └─────┘ │  │ │
│                         │  └───────────────────────────┘  │ │
│                         └─────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Module Structure

- **SSH Module** (`modules/ssh/`): Generates SSH key pairs for secure instance access
- **Network Module** (`modules/network/`): Creates VCN, subnets, security lists, and NSGs
- **Compute Module** (`modules/compute/`): Deploys AMD and ARM compute instances
- **Backup Module** (`modules/backups/`): Implements automated volume backup policies

## 📋 Prerequisites

### Required Software
- **Terraform** (v1.0+)
- **OCI CLI** (latest version)
- **Git**

### OCI Requirements
1. **Active OCI Account** with free tier eligibility
2. **API Keys** configured for OCI CLI authentication
3. **Required Permissions** in your tenancy:
   - Compute Instance Family
   - Network Admin
   - Volume Admin
   - Identity Domain Admin

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd oracle-free-tier
   ```

2. **Configure OCI CLI**
   ```bash
   oci setup config
   ```

3. **Install Terraform**
   ```bash
   # Download and install Terraform
   # https://www.terraform.io/downloads.html
   ```

## 🚦 Quick Start

### 1. Configure Variables

Copy the example variables file and update with your OCI details:

```bash
cp terraform.tfvars.example terraform.tfvars
```

**⚠️ CRITICAL SECURITY WARNING**: The `terraform.tfvars` file contains real OCIDs and must **NEVER** be committed to version control. This file is already in `.gitignore` for your protection.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

### 5. Connect to Instances

After deployment, connect to your instances using the generated SSH keys:

```bash
# AMD Instances
ssh -i keys/oci_compute_private_key ubuntu@<public-ip>

# ARM Instance (if enabled)
ssh -i keys/oci_compute_private_key ubuntu@<public-ip>
```

## 🔧 Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `tenancy_ocid` | Your OCI tenancy OCID | `ocid1.tenancy.oc1..aaaaaaaa...` |
| `user_ocid` | Your OCI user OCID | `ocid1.user.oc1..aaaaaaaa...` |

### Optional Variables

| Variable | Description | Default | Free Tier Limit |
|----------|-------------|---------|----------------|
| `region` | OCI region | `ap-mumbai-1` | - |
| `compartment_name` | Compartment name | `OCI-Free-Compute-Maximal` | - |
| `cidr_block` | VCN CIDR block | `null` (auto-generated) | - |
| `ssh_source_ip` | SSH access IP | `0.0.0.0/0` | Use your IP for security |
| `amd_compute_instance_count` | AMD instances count | `2` | Max 2 |
| `arm_instance_enabled` | Enable ARM instance | `true` | 1 ARM instance |
| `backup_retention_days` | Backup retention | `1` | Max 7 days |
| `key_save_path` | SSH keys path | `keys` | - |

### Example terraform.tfvars

```hcl
# Required: Your tenancy OCID
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaa2nheqtlrvxk667mcesvf5lpkx4ofuhijcumenev2raxc2jt6kvga"

# Optional: Your user OCID
user_ocid = "ocid1.user.oc1..aaaaaaaaqxrkmdtualnivoryz2nbuvr66lndtpnpk6dqmf5b7bxdovabfvua"

# Optional: Region
region = "ap-mumbai-1"

# Optional: SSH source IP (use your actual IP for security)
ssh_source_ip = "49.36.190.125/32"

# Optional: Instance counts
amd_compute_instance_count = 2
arm_instance_enabled = true

# Optional: Backup retention
backup_retention_days = 1
```

## 🔒 Security Analysis

### ⚠️ Critical Security Issues

#### 1. **Real OCIDs in terraform.tfvars**
**Issue**: The `terraform.tfvars` file contains actual OCI resource identifiers (OCIDs) that could expose:
- Your tenancy structure
- User account details
- Organizational information
- Potential attack vectors for targeted attacks

**Risk Level**: **HIGH**

**Example of exposed OCIDs**:
```hcl
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaa2nheqtlrvxk667mcesvf5lpkx4ofuhijcumenev2raxc2jt6kvga"
user_ocid = "ocid1.user.oc1..aaaaaaaaqxrkmdtualnivoryz2nbuvr66lndtpnpk6dqmf5b7bxdovabfvua"
```

#### 2. **SSH Key Exposure**
**Issue**: Generated SSH private keys are stored locally and could be compromised if:
- Local system is compromised
- Keys are not properly secured
- Directory permissions are incorrect

**Risk Level**: **MEDIUM-HIGH**

#### 3. **Open SSH Access**
**Issue**: Default configuration allows SSH from any IP (0.0.0.0/0) which could expose instances to:
- Brute force attacks
- Unauthorized access attempts
- Automated scanning tools

**Risk Level**: **MEDIUM**

### Security Recommendations

#### 1. **Protect OCIDs and Sensitive Data**
- ✅ **DO**: Keep `terraform.tfvars` in `.gitignore` (already configured)
- ✅ **DO**: Use environment variables for sensitive values
- ✅ **DO**: Use OCI Vault for secret management in production
- ❌ **DON'T**: Commit `terraform.tfvars` to version control
- ❌ **DON'T**: Share OCIDs in public repositories
- ❌ **DON'T**: Use real OCIDs in examples or documentation

#### 2. **SSH Security Best Practices**
```bash
# Set restrictive permissions on SSH keys
chmod 600 keys/oci_compute_private_key
chmod 644 keys/oci_compute_private_key.pub

# Use SSH agent instead of storing keys on disk
eval "$(ssh-agent -s)"
ssh-add keys/oci_compute_private_key
```

#### 3. **Network Security**
- **Restrict SSH Access**: Use your actual public IP instead of 0.0.0.0/0
  ```hcl
  ssh_source_ip = "YOUR_ACTUAL_PUBLIC_IP/32"
  ```
- **Implement Security Lists**: Use Network Security Groups for additional protection
- **Enable Logging**: Configure VCN flow logs for traffic monitoring

#### 4. **Instance Security**
- **Regular Updates**: Keep instances updated with latest patches
- **Security Groups**: Implement least privilege principle
- **Monitoring**: Enable OCI monitoring and alerting
- **Backup Verification**: Regularly test backup restoration procedures

#### 5. **Production Hardening**
```hcl
# Enhanced security variables
ssh_source_ip = "YOUR_SPECIFIC_IP/32"     # Restrict SSH access
enable_detailed_monitoring = true         # Enable monitoring
enable_os_patch_management = true         # Automated patching
backup_retention_days = 7                 # Extended retention
```

## 💰 Free Tier Limitations

### Compute Resources
- **AMD Instances**: Max 2 x VM.Standard.E2.1.Micro (1GB RAM, 1 CPU)
- **ARM Instances**: Max 1 x VM.Standard.A1.Flex (up to 4 CPUs, 24GB RAM)
- **Total VMs**: Maximum 3 instances per tenancy

### Storage
- **Boot Volumes**: 200GB total (2 x 100GB blocks)
- **Object Storage**: 10GB
- **Block Volume**: 2 volume backups

### Network
- **VCN**: Unlimited within free tier
- **Public IPs**: Limited allocation
- **Data Transfer**: 10TB outbound per month

### Backup
- **Volume Backups**: 7-day retention maximum on free tier
- **Automated Backups**: Daily incremental backups
- **Manual Backups**: Count toward total backup limit

## 📊 Output Information

After successful deployment, Terraform will display:

### Deployment Summary
```json
{
  "compartment_name": "OCI-Free-Compute-Maximal",
  "region": "ap-mumbai-1",
  "vcn_cidr": "192.168.1.0/24",
  "amd_machine_instances": 2,
  "arm_machine_instance": 1,
  "backup_policy_name": "Daily Backup Policy"
}
```

### SSH Connection Instructions
```bash
# AMD Instance 1
ssh -i keys/oci_compute_private_key ubuntu@129.213.123.123  # AMD Machine 1

# AMD Instance 2  
ssh -i keys/oci_compute_private_key ubuntu@129.213.123.124  # AMD Machine 2

# ARM Instance
ssh -i keys/oci_compute_private_key ubuntu@129.213.123.125  # ARM Machine
```

## 🔧 Troubleshooting

### Common Issues

#### 1. **Authentication Errors**
```bash
# Verify OCI CLI configuration
oci session validate

# Check API keys
ls ~/.oci/
```

#### 2. **Resource Limits Exceeded**
```
Error: Service limits exceeded
```
**Solution**: Ensure you're within free tier limits and don't have existing resources using quotas.

#### 3. **SSH Connection Issues**
```bash
# Check instance status
oci compute instance list --compartment-id <compartment-ocid>

# Verify security list rules
oci network security-list list --vcn-id <vcn-ocid>
```

#### 4. **Terraform State Issues**
```bash
# Refresh state
terraform refresh

# Import existing resources
terraform import oci_core_instance.instance1 <instance-ocid>
```

### Debug Commands

```bash
# Check Terraform plan with debug
terraform plan -var-file="terraform.tfvars" -detailed-exitcode

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show outputs
terraform output
```

## 🗑️ Cleanup

To destroy all created resources:

```bash
terraform destroy
```

**⚠️ Warning**: This will permanently delete all instances, volumes, and backups. Ensure you have backed up any important data.

## 📚 Additional Resources

- [OCI Free Tier Documentation](https://docs.oracle.com/en/cloud/freetier/)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest)
- [OCI CLI Reference](https://docs.oracle.com/en-us/cli/)
- [OCI Security Best Practices](https://docs.oracle.com/en/cloud/security/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This project is for educational and development purposes. Always review and test thoroughly before using in production environments. The authors are not responsible for any costs incurred from OCI resource usage.

---

**Remember**: Always secure your OCIDs and never commit sensitive configuration files to version control! 🔐