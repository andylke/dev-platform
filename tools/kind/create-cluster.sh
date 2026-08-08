#!/usr/bin/env bash

set -euo pipefail

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SERVICE_DIR}/config/kind.yaml"
CLUSTER_NAME="dev-platform"

if ! command -v kind >/dev/null 2>&1; then
    echo "ERROR: kind is not installed." >&2
    exit 1
fi

if kind get clusters | grep -Fxq "$CLUSTER_NAME"; then
    echo "Kind cluster '${CLUSTER_NAME}' already exists."
    exit 0
fi

echo "Creating Kind cluster '${CLUSTER_NAME}'..."

kind create cluster \
    --name "$CLUSTER_NAME" \
    --config "$CONFIG_FILE"

echo "Kind cluster '${CLUSTER_NAME}' created."
