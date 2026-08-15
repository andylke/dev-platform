#!/usr/bin/env bash

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: ${BASH_SOURCE[0]}:${LINENO}: ${BASH_COMMAND} (exit ${rc})" >&2' ERR

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SHARE_DIR}/foreach-service.sh"
source "${SHARE_DIR}/set-env.sh"


cleanup_ca_cert() {

    local ca_cert_dir="${SHARE_DIR}/ca-certificates"

    find "${ca_cert_dir}" -mindepth 1 -print -delete

}

cleanup_ca_cert

echo
echo "Cleanup CA cert completed."


