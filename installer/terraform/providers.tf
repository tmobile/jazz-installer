provider "aws" {
  version = "~> 1.41"
  region = "${var.region}"
}

provider "null" {
  version = "~> 1.0"
}
# To create the log destinations in the supported regions using terraform alias
provider "aws" {
  alias  = "east1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west2"
  region = "us-west-2"
}
