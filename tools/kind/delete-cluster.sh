#!/usr/bin/env bash

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: ${BASH_SOURCE[0]}:${LINENO}: ${BASH_COMMAND} (exit ${rc})" >&2' ERR

SHARED_DIR="$(cd "$(dirname "$0")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

if ! command -v kind >/dev/null 2>&1; then
    echo "ERROR: kind is not installed." >&2
    exit 1
fi

if ! kind get clusters | grep -Fxq "$KIND_CLUSTER_NAME"; then
    echo "Kind cluster '${KIND_CLUSTER_NAME}' does not exist."
    exit 0
fi

kind delete cluster \
    --name "$KIND_CLUSTER_NAME"
