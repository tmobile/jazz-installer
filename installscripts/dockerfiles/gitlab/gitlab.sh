#!/bin/bash
passwd=$1
chmod -R 777 /var/opt/gitlab
yes yes| /opt/gitlab/bin/gitlab-rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=$passwd > ~/out.txt 2>&1
grep -A4 Administrator ~/out.txt | tee -a ~/gitlab-creds.txt
