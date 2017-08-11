resource "null_resource" "outputVariables" {
  provisioner "local-exec" {
    command = "./scripts/createNetVars.sh ${aws_subnet.demo.id} ${var.netVarsfile} "
  }
}
