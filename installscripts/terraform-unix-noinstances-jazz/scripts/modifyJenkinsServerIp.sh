#!/bin/bash

sed -i "s/default\['server'\]\['privateip'\].*.$/default['server']['privateip']='$1'/g" $2