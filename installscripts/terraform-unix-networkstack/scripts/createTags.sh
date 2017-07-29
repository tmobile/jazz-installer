#!/bin/bash
ENVPREFIX=$1
APPLICATION=$2
ENVIRONMENT=$3
EXEMPT=$4
OWNER=$5
TAGSFILE=$6
sed -i "s|variable \"envPrefix\" { type = \"string\"  default.*.$|variable \"envPrefix\" { type = \"string\"  default = \"$ENVPREFIX\" }|g" $TAGSFILE
sed -i "s|variable \"tagsApplication\" { type = \"string\"  default.*.$|variable \"tagsApplication\" { type = \"string\"  default = \"$APPLICATION\" }|g" $TAGSFILE
sed -i "s|variable \"tagsEnvironment\" {type = \"string\" default.*.$|variable \"tagsEnvironment\" {type = \"string\" default = \"$ENVIRONMENT\" }|g" $TAGSFILE
sed -i "s|variable \"tagsExempt\" { type = \"string\" default.*.$|variable \"tagsExempt\" { type = \"string\" default = \"$EXEMPT\" }|g" $TAGSFILE
sed -i "s|variable \"tagsOwner\" { type = \"string\" default.*.$|variable \"tagsOwner\" { type = \"string\" default = \"$OWNER\" }|g" $TAGSFILE
