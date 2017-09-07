#!/bin/bash

property_key=$1
property_value=$2
property_file=$3

sed -i "s/$property_key.*.$/$property_key=$property_value/g" $property_file

