provider "aws" {
  version = "~> 1.41"
  region = "${var.region}"
}

provider "null" {
  version = "~> 1.0"
}
