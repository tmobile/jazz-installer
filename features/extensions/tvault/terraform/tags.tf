locals {
  common_tags = "${map(
  "Name", "${var.envPrefix}",
  "Application", "Jazz",
  "JazzInstance", "${var.envPrefix}"
  )}"
}
