#!/bin/bash
scm_username=$1
scm_passwd=$2
scm_elb=$3
scm_path=$4
cognito_pool_username=$5

git clone http://"$scm_username":"$scm_passwd"@"$scm_elb""$scm_path"/slf/jazz-build-module.git --depth 1
cd jazz-build-module || exit
cp "$JAZZ_INSTALLER_ROOT"/installer/terraform/cookbooks/jenkins/files/default/jazz-installer-vars.json .
git add jazz-installer-vars.json
git config --global user.email "$cognito_pool_username"
git commit -m 'Adding Json file to repo'
git push -u origin master
cd .. || exit
sudo rm -rf jazz-build-module
