#!/bin/bash
SUBNET=$1
NETVARSFILE=$2
sed -i "s|variable \"subnet\" {type = \"string\" default.*.$|variable \"subnet\" {type = \"string\" default = \"$SUBNET\" }|g" $NETVARSFILE
