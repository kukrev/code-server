#!/usr/bin/env bash
set -euo pipefail

# Packages code-server for the current OS and architecture into ./release-packages.
# This script assumes that a standalone release is built already into ./release-standalone

main() {
  cd "$(dirname "${0}")/../.."
  source ./ci/lib.sh

  mkdir -p release-packages

  release_archive

  if [[ $OS == "linux" ]]; then
    release_nfpm
  fi
}

release_archive() {
  local release_name="code-server-$VERSION-$OS-$ARCH"
  if [[ $OS == "linux" ]]; then
    tar -czf "release-packages/$release_name.tar.gz" --transform "s/^\.\/release-standalone/$release_name/" ./release-standalone
  else
    tar -czf "release-packages/$release_name.tar.gz" -s "/^release-standalone/$release_name/" release-standalone
  fi

  echo "done (release-packages/$release_name)"
}

# Generates deb and rpm packages.
release_nfpm() {
  local nfpm_config
  nfpm_config="$(envsubst < ./ci/build/nfpm.yaml)"

  # The underscores are convention for .deb.
  nfpm pkg -f <(echo "$nfpm_config") --target "release-packages/code-server_${VERSION}_$ARCH.deb"
  nfpm pkg -f <(echo "$nfpm_config") --target "release-packages/code-server-$VERSION-$ARCH.rpm"
}

main "$@"
