#!/bin/bash

sed -i "s/default\['slave'\]\['publicip'\].*.$/default['slave']['publicip']='$1'/g" $2