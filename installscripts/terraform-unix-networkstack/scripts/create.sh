#!/bin/bash
cidrblocks=$1
date
terraform apply -var "cidrblocks=$cidrblocks"
date
echo " ======================================================="
echo " The following Stack has been created in AWS"
echo " ________________________________________________"
terraform state list

