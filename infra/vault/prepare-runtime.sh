#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
VOLUMES_DIR="${RUNTIME_DIR}/volumes"

prepare_data_dir() {

    local data_dir="${VOLUMES_DIR}/data"

    mkdir -p "${data_dir}"

    docker run --rm \
        --user 0:0 \
        -v "${data_dir}:/vault/data" \
        "hashicorp/vault:${VAULT_VERSION}" \
        sh -c '
            chown -R "$(id -u vault):$(id -g vault)" /vault/data
            chmod 700 /vault/data
        '

}

prepare_data_dir
