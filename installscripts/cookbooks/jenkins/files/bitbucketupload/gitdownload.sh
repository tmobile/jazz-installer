#!/bin/bash
git clone https://github.com/tmobile/jazz.git jazz-core
find -type d -name ".git" -exec rm -rf {} \;
mv -vf jazz-core jazz-core-git
cp -rf bitbucketpush.sh jazz-core-git
