#!/usr/bin/env bash

set -euo pipefail

SHARE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../share" && pwd)"
source "${SHARE_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
CONFIG_DIR="${RUNTIME_DIR}/config"

generate_config_files() {

    mkdir -p "${CONFIG_DIR}"

    cat > "${CONFIG_DIR}/Caddyfile" <<EOF
(dev_tls) {
    tls /certificates/caddy.crt /certificates/caddy.key
}

${JENKINS_DOMAIN} {
    import dev_tls
    reverse_proxy jenkins:8080
}

${MAILPIT_DOMAIN} {
    import dev_tls
    reverse_proxy mailpit:8025
}

${GRAFANA_DOMAIN} {
    import dev_tls
    reverse_proxy grafana:3000
}
EOF

}

generate_config_files
