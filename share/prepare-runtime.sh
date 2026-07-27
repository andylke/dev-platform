#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SHARE_DIR}/foreach-service.sh"
source "${SHARE_DIR}/set-env.sh"

prepare_dir() {

    local service=$1
    local runtime_dir=$2

    echo
    echo "# Preparing runtime dir for ${service}"

    mkdir -p \
      "${runtime_dir}/volumes"

}

call_prepare_runtime_script() {

    local service=$1
    local service_dir=$2

    local script="${service_dir}/prepare-runtime.sh"
    if [[ -f "$script" ]]; then

        echo
        echo "# Calling ${script}"

        "${script}"

    fi

}

prepare_runtime() {

    local service="$1"

    local service_dir="${ROOT_DIR}/${service}"
    local runtime_dir="${service_dir}/runtime"

    prepare_dir "${service}" "${runtime_dir}"
    call_prepare_runtime_script "${service}" "${service_dir}"

    tree -pug "${runtime_dir}"

}

foreach_service prepare_runtime "$@"

echo
echo "Prepare runtime for all services completed."


