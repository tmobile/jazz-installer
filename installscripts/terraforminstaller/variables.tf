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
    key_name = "ec2_rsa"
    public_key = "../sshkeys/ec2_rsa.pub"
    private_key = "../sshkeys/ec2_rsa.pem"
  }
}
