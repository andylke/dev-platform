#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SHARE_DIR}/foreach-service.sh"
source "${SHARE_DIR}/set-env.sh"

cleanup_dir() {

    local service=$1
    local cert_dir=$2

    echo
    echo "# Cleaning cert dir for ${service}"

    find "${cert_dir}" -mindepth 1 -print -delete

}

cleanup_cert() {

    local service="$1"

    local service_dir="${ROOT_DIR}/${service}"
    local cert_dir="${service_dir}/certificates"

    cleanup_dir "${service}" "${cert_dir}"

    tree -pug "${cert_dir}"

}

foreach_service cleanup_cert "$@"

echo
echo "Cleanup cert for all services completed."


