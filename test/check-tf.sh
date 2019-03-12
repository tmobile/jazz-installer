#!/usr/bin/env bash
# This is inspired by:
# https://github.com/mozilla-platform-ops/devservices-aws/blob/master/runtests.sh
set -euo pipefail

echo -e '\n-----> Running terraform validate'
cd "$TRAVIS_BUILD_DIR/installer/terraform/"
terraform init
terraform validate
echo -e '\n-----> Success!'
