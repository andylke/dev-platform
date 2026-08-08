#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local/bin"

uninstall_kind() {
    if ! command -v kind >/dev/null 2>&1; then
        echo "kind not installed"
        return
    fi

    if kind get clusters 2>/dev/null | grep -q .; then
        echo "Kind clusters found:"
        kind get clusters

        echo "Delete the clusters before uninstalling kind."
        return 1
    fi

    local version
    version=$(kind version)

    sudo rm -f "${INSTALL_DIR}/kind"

    echo "Uninstalled kind: ${version}"
}

uninstall_kind
