#!/usr/bin/env bash

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: ${BASH_SOURCE[0]}:${LINENO}: ${BASH_COMMAND} (exit ${rc})" >&2' ERR

SHARED_DIR="$(cd "$(dirname "$0")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SERVICE_DIR}/config/kind.yaml"

if ! command -v kind >/dev/null 2>&1; then
    echo "ERROR: kind is not installed." >&2
    exit 1
fi

if kind get clusters | grep -Fxq "$KIND_CLUSTER_NAME"; then
    echo "Kind cluster '${KIND_CLUSTER_NAME}' already exists."
    exit 0
fi

echo "Creating Kind cluster '${KIND_CLUSTER_NAME}'..."

kind create cluster \
    --name "$KIND_CLUSTER_NAME" \
    --config "$CONFIG_FILE"

echo "Kind cluster '${KIND_CLUSTER_NAME}' created."

if ! docker network inspect "$BACKEND_NETWORK" >/dev/null 2>&1; then
    echo "Creating Docker network '${BACKEND_NETWORK}'..."
    docker network create \
      --label com.docker.compose.network=backend \
      "$BACKEND_NETWORK"
fi

echo "Connecting Kind nodes to '${BACKEND_NETWORK}'..."

while IFS= read -r node; do
    docker network connect "$BACKEND_NETWORK" "$node"
done < <(kind get nodes --name "$KIND_CLUSTER_NAME")

echo "Kind cluster '${KIND_CLUSTER_NAME}' created."
echo "Kind nodes connected to '${BACKEND_NETWORK}'."

