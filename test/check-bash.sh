#!/usr/bin/env bash

if [[ -z "$TRAVIS_PULL_REQUEST_BRANCH" ]]; then
  BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
else
  BRANCH="master"
fi

echo "Diffing with " $BRANCH "and TRAVIS_BRANCH is " "$TRAVIS_BRANCH"

for file in $(git diff --name-only $BRANCH | grep .sh\$); do
  # Globally ignore lint error SC2024: https://github.com/koalaman/shellcheck/wiki/SC2024
  # as I don't think it's an important check for our use case
  shellcheck -e SC2024 "$file"
done
