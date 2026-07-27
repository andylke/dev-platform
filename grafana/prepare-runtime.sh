#!/usr/bin/env bash

set -euo pipefail

SHARE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../share" && pwd)"
source "${SHARE_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
VOLUMES_DIR="${RUNTIME_DIR}/volumes"

prepare_data_dir() {

    local data_dir="${VOLUMES_DIR}/data"

    mkdir -p "${data_dir}"

    chmod 755 "${data_dir}"
    sudo chown -R 472:472 "${data_dir}"

}

prepare_data_dir
