#!/bin/bash

property_key=$1
property_value=$2
property_file=$3
property_file_json=
property_value=$(sed 's/[]\/$*.^|[]/\\&/g' <<< $property_value)

sed -i "s/$property_key.*.$/$property_key=$property_value/g" $property_file

#JSON Format
sed -i "s/$property_key\".*.$/$property_key\": \"$property_value\"/g" $property_file_json

