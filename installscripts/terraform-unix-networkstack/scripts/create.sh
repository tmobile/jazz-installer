#!/bin/bash
cidrblocks=$1
date
terraform apply -var "cidrblocks=$cidrblocks"
date
echo " ======================================================="
echo " The following Stack has been created in AWS"
echo " ________________________________________________"
terraform state list
echo " ======================================================="
echo " Once checkout is done Please execute nohup ./scripts/destroy.sh & in the following directory . This will cleanup the entire Stack"
pwd
echo " ======================================================="
