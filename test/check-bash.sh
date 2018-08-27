#!/usr/bin/env bash
# This is inspired by:
# https://github.com/mozilla-platform-ops/devservices-aws/blob/master/runtests.sh
set -euo pipefail
main() {
  echo -e '\n-----> Running shellcheck'
  for d in $(git ls-files '*.sh' | xargs -n1 dirname | LC_ALL=C sort | uniq); do
    echo -en "${d} "
    shellcheck "${d}"
    echo "✓"
  done
  echo -e '\n-----> Success!'
}
main "$@"
