#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

INSTALL_DIR="/usr/local/bin"

install_kind() {
    if command -v kind >/dev/null 2>&1; then
        echo "kind already installed: $(kind version)"
        return
    fi

    local tmp_file
    tmp_file="$(mktemp)"

    curl -fL \
        "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64" \
        -o "$tmp_file"

    chmod +x "$tmp_file"
    sudo mv "$tmp_file" "${INSTALL_DIR}/kind"

    echo "Installed kind: $(kind version)"
}

install_kind
