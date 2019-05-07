# Subfolder Layout

* `provisioners` - Everything that touches resources that have already been created by Terraform should live in this folder.
                   Chef cookbooks, Config scripts for existing Jenkins servers, etc
* `scripts` - Any _non-provisioning_ external scripts that Terraform needs to run should live in this folder. There should be few of these scripts, and they should be written in Python3.

# Terraform Code Best Practices

1. Keep resource declarations at the top level. This makes it easier to change and delete resources, and track their dependencies.

2. Use modules.

3. Keep `resource` creation tasks (pure Terraform) and `provision` tasks (stuff that drops out of Terraform to run external scripts/tools) in separate, purpose-specific files, e.g. `s3bucket.tf` and `jenkins.tf` (one creates buckets, the other uses info from created buckets to configure Jenkins property files)

4. Declare variables in `variables.tf`. Set input (user-created) values for those variables in `terraform.tfvars`.

5. Run `https://github.com/wata727/tflint` to validate your changes.
