#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
CONFIG_DIR="${RUNTIME_DIR}/config"

generate_config_files() {

    mkdir -p "${CONFIG_DIR}"

    cat > "${CONFIG_DIR}/redis.conf" <<EOF
bind 0.0.0.0
protected-mode yes

port 0
tls-port 6379

tls-cert-file /certificates/redis.crt
tls-key-file /certificates/redis.key
tls-ca-cert-file /ca-certificates/ca.crt

tls-auth-clients no

aclfile /usr/local/etc/redis/users.acl

dir /data

appendonly yes
EOF

    cat > "${CONFIG_DIR}/users.acl" <<EOF
user default off
user ${REDIS_ADMIN_USERNAME} on >${REDIS_ADMIN_PASSWORD} ~* +@all
EOF
}

generate_config_files
