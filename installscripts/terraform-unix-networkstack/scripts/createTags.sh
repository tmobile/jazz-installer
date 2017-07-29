#!/bin/bash
ENVPREFIX=$1
APPLICATION=$2
ENVIRONMENT=$3
EXEMPT=$4
OWNER=$5
TAGSFILE=$6
sed -i "s|variable \"envPrefix\".*.$|variable \"envPrefix\" \{ type = \"string\"  default = \"$ENVPREFIX\" \}|g" $TAGSFILE
sed -i "s|variable \"tagsApplication\".*.$|variable \"tagsApplication\" \{ type = \"string\"  default = \"$APPLICATION\" \}|g" $TAGSFILE
sed -i "s|variable \"tagsEnvironment\".*.$|variable \"tagsEnvironment\" \{type = \"string\" default = \"$ENVIRONMENT\" \}|g" $TAGSFILE
sed -i "s|variable \"tagsExempt\".*.$|variable \"tagsExempt\" \{ type = \"string\" default = \"$EXEMPT\" \}|g" $TAGSFILE
sed -i "s|variable \"tagsOwner\".*.$|variable \"tagsOwner\" \{ type = \"string\" default = \"$OWNER\" \}|g" $TAGSFILE
