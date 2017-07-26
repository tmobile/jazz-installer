variable "region" {
  type = "string"
  default = "us-east-1"
}
variable "envPrefix" {
  type = "string"
  default = "Installerlatest"
}
variable "vpc" {
  type = "string"
  default = "Installer"
}
variable "subnet" {
  type = "string"
  default = "Installer"
}
variable "installer_ami" {
  type = "string"
  default = "ami-d284bec4"
}

variable "keypair" {
  type = "map"

  default = {
    key_name = "ustglobal_rsa"
    public_key = "../sshkeys/ustglobal_rsa.pub"
    private_key = "../sshkeys/ustglobal_rsa.pem"
  }
}
