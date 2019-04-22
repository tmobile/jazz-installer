#!/bin/bash

# TODO should be ported to python3 + sed dep dropped
# TODO We should not be updating the same file 3 different ways (by stub value, by key, etc)
# we should pick one method and stick to it for all properties in jazz-installer-vars.json
property_key=$1
property_value=$2
property_file_json=$3
method=$4 # Should be BY_KEY, BY_VALUE, ARRAY or empty. If empty, will default to "BY_KEY"
# BY_KEY will look for the given key and replace the value to the right of it
# BY_VALUE will look for a magic string/default value and replace that, like {AWS_PROD_API_DEFAULT}
# ARRAY is used for AWS tags

property_value=$(sed 's/[]\/$*.^|[]/\\&/g' <<< "$property_value")
if [ "$method" == "ARRAY" ]; then
  property_value=$(sed "s/'/\"/g" <<< "$property_value")
  sed -i "s/$property_key\".*.$/$property_key\" : $property_value/g" "$property_file_json"
elif [ "$method" == "BY_VALUE" ]; then
  sed -i "s/$property_key/$property_value/g" "$property_file_json"
else #this is the BY_KEY case (default)
  sed -i "s/\"$property_key\".*\"\"/\"$property_key\" : \"$property_value\"/g" "$property_file_json"
fi
