#!/usr/bin/env bash

set -euo pipefail

SHARE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../share" && pwd)"
source "${SHARE_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
CONFIG_DIR="${RUNTIME_DIR}/config"

prepare_runtime_cert() {

    local ca_cert_dir="${SHARE_DIR}/ca-certificates"
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

generate_config_files() {

    mkdir -p "${CONFIG_DIR}"

    cat > "${CONFIG_DIR}/pg_hba.conf" <<EOF
# Local socket
local   all             all                                 scram-sha-256

# SSL connections
hostssl all             all             0.0.0.0/0           scram-sha-256
hostssl all             all             ::/0                scram-sha-256

# Non-SSL connections
host    all             all             0.0.0.0/0           scram-sha-256
host    all             all             ::/0                scram-sha-256
EOF

    cat > "${CONFIG_DIR}/postgresql.conf" <<EOF
listen_addresses='*'

port=${POSTGRESQL_PORT}

ssl=on

ssl_cert_file='/certificates/postgresql.crt'
ssl_key_file='/certificates/postgresql.key'
ssl_ca_file='/certificates/ca.crt'

password_encryption=scram-sha-256

max_connections=100

shared_buffers=512MB

timezone='Asia/Kuala_Lumpur'

logging_collector=on
log_directory='log'
log_filename='postgresql-%Y-%m-%d.log'

log_connections=on
log_disconnections=on
EOF

}

prepare_runtime_cert
generate_config_files
