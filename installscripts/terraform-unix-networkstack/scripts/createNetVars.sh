#!/bin/bash
VPC=$1
SUBNET=$2
CIDRBLOCKS=$3
NETVARSFILE=$4
sed -i "s|variable \"subnet\" {type = \"string\" default.*.$|variable \"subnet\" {type = \"string\" default = \"$SUBNET\" }|g" $NETVARSFILE
