#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

INSTALL_DIR="/usr/local/bin"


install_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        echo "kubectl already installed: $(kubectl version --client --output=yaml | grep gitVersion | head -1)"
        return
    fi

    local tmp_file
    tmp_file="$(mktemp)"

    curl -fL \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
        -o "$tmp_file"

    chmod +x "$tmp_file"
    sudo mv "$tmp_file" "${INSTALL_DIR}/kubectl"

    echo "Installed kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
}

install_kubectl
