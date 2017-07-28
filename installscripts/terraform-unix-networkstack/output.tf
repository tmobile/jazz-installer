resource "null_resource" "outputVariables" {
  provisioner "local-exec" {
    command = "./scripts/createNetVars.sh ${aws_vpc.demo.id} ${aws_subnet.demo.id} 10.0.0.0/16 ${var.netVarsfile} "
  }
}
