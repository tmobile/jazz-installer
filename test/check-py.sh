#!/usr/bin/env bash

if [[ -z "$TRAVIS_PULL_REQUEST_BRANCH" ]]; then
  BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
else
  BRANCH="master"
fi

exitcode=0
for file in $(git diff --name-only $BRANCH | grep .py\$); do
  if [[ "$(flake8 "$file")" -gt 0 ]]; then
    echo "ERROR: $file failed to pass Python lint step"
    exitcode=1
  fi
done
exit $exitcode
