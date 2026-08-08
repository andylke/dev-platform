#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
AUTH_DIR="${RUNTIME_DIR}/auth"

prepare_auth_htpasswd() {

    mkdir -p "${AUTH_DIR}"

    docker run --rm \
        --entrypoint htpasswd \
        httpd:2 \
        -Bbn \
        "${REGISTRY_ADMIN_USERNAME}" \
        "${REGISTRY_ADMIN_PASSWORD}" \
        > "${AUTH_DIR}/htpasswd"

}

prepare_auth_htpasswd
