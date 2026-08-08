#!/usr/bin/env bash

set -euo pipefail

uninstall_pack() {

    if ! command -v pack >/dev/null 2>&1; then
        echo "pack not installed"
        return
    fi

    local version
    version="$(pack --version)"

    sudo rm -f /usr/local/bin/pack

    echo "Uninstalled pack: ${version}"
}

uninstall_pack
