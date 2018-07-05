## Summary
- **Installer scripts should only set and pass values to Terraform**
- **Terraform should only set and pass values to Chef**
- **Terraform should only instantiate things, Chef should only provision/configure/do things.**

**Set Terraform values in /jazz-terraform-unix-noinstances/terraform.tfvars**
**Set Chef cookbook values in /cookbooks/jenkins/attributes/default.rb**

## Where/how to set Terraform and Chef variables.
**As of now, the only Chef-related file that should be touched with `sed` is `cookbooks/jenkins/attributes/default.rb`. This is where all the variables and values that Chef is aware of should live, and any values a script needs should be passed in by Chef from those variables, not `sed`ed into the script from Terraform or the installer.**

Summary of the layers now:
- **Installer scripts should only set and pass values to Terraform**
-- **Set Terraform values in /jazz-terraform-unix-noinstances/terraform.tfvars**
- **Terraform should only set and pass values to Chef**
-- **Set Chef cookbook values in /cookbooks/jenkins/attributes/default.rb**

To keep things tidy recommend we do not break this separation, and reject PRs that do.

## Adding more 3rd party Chef recipies
It is easy to add more [3rd party recipes from the Chef Supermarket](https://supermarket.chef.io/) if we need to:
1. Add the new cookbook you want to use to `cookbooks/Policyfile.rb`
2. Edit the `metadata.rb` of the cookbook from which you want to use the external cookbook and add a `depends` line.
3. Use `include_recipe` from your recipe to run the external cookbook's recipe (see `prereqs.rb` recipe for an example of a recipe that includes/runs other recipes).
