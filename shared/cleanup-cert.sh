#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SHARED_DIR}/set-env.sh"
source "${SHARED_DIR}/foreach-service.sh"

cleanup_cert() {

    local service_dir=$1
    local service=$2
    local cert_dir="${service_dir}/certificates"

    echo
    echo "# Cleaning cert directory for ${service}"

    find "${cert_dir}" -mindepth 1 -print -delete

    tree -pug "$cert_dir"

}

foreach_service cleanup_cert "$@"

echo
echo "Cleanup cert for all services completed."


