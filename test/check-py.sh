#!/usr/bin/env bash

set -eo pipefail

bold=$(tput bold)
normal=$(tput sgr0)

if [[ -z "$TRAVIS_BRANCH" ]]; then
  BRANCH="$TRAVIS_BRANCH"
else
  BRANCH="master"
fi

echo "Diffing with" "$BRANCH"

for file in $(git diff --name-only "$TRAVIS_BRANCH" | grep .py\$); do
  echo "Checking ${bold}$file${normal}..."
  flake8 "$file"
done
