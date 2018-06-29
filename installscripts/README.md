- **Installer scripts should only set and pass values to Terraform**
- **Terraform should only set and pass values to Chef**

**DO NOT VIOLATE THIS SEPARATION**

**Set Terraform values in /jazz-terraform-unix-noinstances/terraform.tfvars**
**Set Chef cookbook values in /cookbooks/jenkins/attributes/default.rb**
