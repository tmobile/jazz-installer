#!/usr/bin/env bash

set -eo pipefail

bold=$(tput bold)
normal=$(tput sgr0)

echo "Diffing commit range" "$TRAVIS_COMMIT_RANGE"

# Get changed file names, excluding deleted files
for file in $(git diff --diff-filter=d --name-only "$TRAVIS_COMMIT_RANGE" | grep .py\$); do
  echo "Checking ${bold}$file${normal}..."
  flake8 "$file"
done
