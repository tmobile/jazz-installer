#!/usr/bin/env bash

set -eo pipefail

bold=$(tput bold)
normal=$(tput sgr0)

# if [[ -z $TRAVIS_BRANCH ]]; then
#   BRANCH="$TRAVIS_BRANCH"
# else
#   BRANCH="master"
# fi

echo "Diffing with" "$$TRAVIS_COMMIT_RANGE"

for file in $(git diff --name-only "$$TRAVIS_COMMIT_RANGE" | grep .sh\$); do
  # Globally ignore lint error SC2024: https://github.com/koalaman/shellcheck/wiki/SC2024
  # as I don't think it's an important check for our use case
  echo "Checking ${bold}$file${normal}..."
  shellcheck -e SC2024 $file
done
