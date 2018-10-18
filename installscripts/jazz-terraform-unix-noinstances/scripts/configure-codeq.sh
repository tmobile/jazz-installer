#!/bin/bash

ip=$1
passwd=$2
curl -u admin:admin -X POST -F 'name=JazzProfile' -F 'language=java' http://"$ip":9000/api/qualityprofiles/create
curl -u admin:admin -X POST -F 'name=JazzProfile' -F 'language=js' http://"$ip":9000/api/qualityprofiles/create
curl -u admin:admin -X POST -F 'name=JazzProfile' -F 'language=py' http://"$ip":9000/api/qualityprofiles/create
# shellcheck disable=SC2086
curl -u admin:admin -X POST -F 'login=admin' -F 'password='''$passwd'''' -F 'previousPassword=admin' http://$ip:9000/api/users/change_password

sleep 10 &
curl -u admin:"$passwd" -X POST http://"$ip":9000/api/system/restart
