provider "aws" {
  version = "~> 1.29"
  region = "${var.region}"
}

provider "archive" {
  version = "~> 1.1"
}
