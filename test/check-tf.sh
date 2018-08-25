#!/usr/bin/env bash
# This is inspired by:
# https://github.com/mozilla-platform-ops/devservices-aws/blob/master/runtests.sh
set -euo pipefail
main() {
  echo -e '\n-----> Running terraform validate'
  terraform init
  for d in $(git ls-files '*.tf' | xargs -n1 dirname | LC_ALL=C sort | uniq); do
    echo -en "${d} "
    terraform validate "${d}"
    echo "✓"
  done
  echo -e '\n-----> Success!'
}
main "$@"
