locals {
  common_tags = "${map(
  "Name", "${var.envPrefix}",
  "Application", "Jazz",
  "JazzInstance", "${var.envPrefix}",
  "Environment", "${var.tagsEnvironment}",
  "Exempt", "${var.tagsExempt}",
  "Owner", "${var.tagsOwner}"
  )}"
}
