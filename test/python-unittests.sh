#!/usr/bin/env bash
# This is inspired by:
# https://github.com/mozilla-platform-ops/devservices-aws/blob/master/runtests.sh
set -euo pipefail

echo -e '\n-----> Running Python unit tests'
cd "$TRAVIS_BUILD_DIR/installer/"
python -m unittest discover
echo -e '\n-----> Success!'
