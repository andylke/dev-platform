#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
CONFIG_DIR="${RUNTIME_DIR}/config"

generate_config_files() {

    mkdir -p "${CONFIG_DIR}"

    cat > "${CONFIG_DIR}/smtp-auth.txt" <<EOF
${MAILPIT_ADMIN_USERNAME}:${MAILPIT_ADMIN_PASSWORD}
EOF

    cat > "${CONFIG_DIR}/ui-auth.txt" <<EOF
${MAILPIT_ADMIN_USERNAME}:${MAILPIT_ADMIN_PASSWORD}
EOF

}

generate_config_files
