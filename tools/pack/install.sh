#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

INSTALL_DIR="/usr/local/bin"

install_pack() {
    if command -v pack >/dev/null 2>&1; then
        echo "pack already installed: $(pack --version)"
        exit 0
    fi

    tmp_file="$(mktemp)"

    curl -fL \
        "https://github.com/buildpacks/pack/releases/download/${PACK_VERSION}/pack-${PACK_VERSION}-linux.tgz" \
        -o "$tmp_file"

    sudo tar \
        -C "$INSTALL_DIR" \
        -xzf "$tmp_file"

    rm -f "$tmp_file"

    echo "Installed pack: $(pack --version)"
}

install_pack
