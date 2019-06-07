Please try to follow these conventions when adding new code:

- jazz-installer
  - (platform-specific prerequisite installer scripts)
  - feature-extensions
  - installer
    - cli (the installer logic, Click modules and submodules)
    - configurators (code that needs to configure Jenkins/Gitlab/Sonar/etc before the Terraform execution step)
    - helpers (general shared functions)
    - terraform (all Terraform resources are in this folder, including external scripts that Terraform invokes)
