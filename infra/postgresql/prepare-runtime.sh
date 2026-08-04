#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
CONFIG_DIR="${RUNTIME_DIR}/config"

prepare_runtime_cert() {

    local ca_cert_dir="${SHARED_DIR}/ca-certificates"
    local cert_dir="${SERVICE_DIR}/certificates"
    local runtime_cert_dir="${RUNTIME_DIR}/certificates"

    mkdir -p "${runtime_cert_dir}"

    cp "${ca_cert_dir}/ca.crt" "${runtime_cert_dir}/"
    cp "${cert_dir}/postgresql.crt" "${runtime_cert_dir}/"
    cp "${cert_dir}/postgresql.key" "${runtime_cert_dir}/"

    docker run --rm \
      -v "${runtime_cert_dir}:/certificates" \
      postgres:${POSTGRESQL_VERSION} \
      bash -c "
        chown postgres:postgres /certificates/ca.crt
        chown postgres:postgres /certificates/postgresql.crt
        chown postgres:postgres /certificates/postgresql.key
        chmod 600 /certificates/postgresql.key
      "

}

prepare_runtime_cert
