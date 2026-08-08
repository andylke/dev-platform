#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local/bin"


uninstall_kubectl() {
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "kubectl not installed"
        return
    fi

    local version
    version=$(kubectl version --client --short 2>/dev/null || kubectl version --client)

    sudo rm -f "${INSTALL_DIR}/kubectl"

    echo "Uninstalled kubectl: ${version}"
}

uninstall_kubectl

