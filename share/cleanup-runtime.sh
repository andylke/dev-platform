#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SHARE_DIR}/foreach-service.sh"
source "${SHARE_DIR}/set-env.sh"

cleanup_dir() {

    local service=$1
    local runtime_dir=$2

    echo
    echo "# Cleaning runtime dir for ${service}"

    sudo find "${runtime_dir}" -mindepth 1 -print -delete

}

call_cleanup_runtime_script() {

    local service=$1
    local service_dir=$2

    local script="${service_dir}/cleanup-runtime.sh"
    if [[ -f "$script" ]]; then

        echo
        echo "# Calling ${script}"

        "${script}"

    fi

}

cleanup_runtime() {

    local service="$1"

    local service_dir="${ROOT_DIR}/${service}"
    local runtime_dir="${service_dir}/runtime"

    call_cleanup_runtime_script "${service}" "${service_dir}"
    cleanup_dir "${service}" "${runtime_dir}"

    tree -pug "${runtime_dir}"

}

foreach_service cleanup_runtime "$@"

echo
echo "Cleanup runtime for all services completed."


