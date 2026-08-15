#!/usr/bin/env bash

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: ${BASH_SOURCE[0]}:${LINENO}: ${BASH_COMMAND} (exit ${rc})" >&2' ERR

SHARED_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SHARED_DIR}/set-env.sh"
source "${SHARED_DIR}/foreach-service.sh"

cleanup_runtime() {

    local service_dir=$1
    local service=$2
    local runtime_dir="${service_dir}/runtime"

    local script="${service_dir}/cleanup-runtime.sh"
    if [[ -f "$script" ]]; then
        echo
        echo "# Calling ${script}"
        "${script}"
    fi

    echo
    echo "# Cleaning runtime dir for ${service}"
    sudo find "${runtime_dir}" -mindepth 1 -print -delete

    tree -pug "$runtime_dir"

}

foreach_service cleanup_runtime "$@"

echo
echo "Cleanup runtime for all services completed."


