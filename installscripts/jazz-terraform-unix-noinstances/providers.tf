provider "aws" {
  version = "~> 1.14"
  region = "${var.region}"
}

provider "null" {
  version = "~> 1.0"
}
