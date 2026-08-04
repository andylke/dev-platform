#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SHARED_DIR}/set-env.sh"
source "${SHARED_DIR}/foreach-service.sh"

prepare_runtime() {

    local service_dir=$1
    local service=$2
    local runtime_dir="${service_dir}/runtime"

    echo
    echo "# Preparing runtime dir for ${service}"
    mkdir -p \
      "${runtime_dir}/volumes"

    local script="${service_dir}/prepare-runtime.sh"
    if [[ -f "$script" ]]; then
        echo
        echo "# Calling ${script}"
        "${script}"
    fi

    tree -pug "${runtime_dir}"

}

foreach_service prepare_runtime "$@"

echo
echo "Prepare runtime for all services completed."


