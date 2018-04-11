# Terraform Best Practices
1. Keep resource declarations at the top level. This makes it easier to change and delete resources, and track their dependencies.

2. Use modules.

3. Keep resource creation and provisioning steps separate.

4. Declare variables in `variables.tf`. Set input (user-created) values for those variables in `terraform.tfvars`.

5. Run `https://github.com/wata727/tflint` to validate your changes.
