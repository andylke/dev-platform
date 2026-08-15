#!/usr/bin/env bash

set -euo pipefail

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
INIT_FILE="${RUNTIME_DIR}/init.json"

CONTAINER_NAME="vault"
VAULT_ADDR="http://127.0.0.1:8200"

get_status() {
    local status="$(
        docker exec \
            -e VAULT_ADDR="${VAULT_ADDR}" \
            "${CONTAINER_NAME}" \
            vault status -format=json 2>/dev/null || true
    )"

    INITIALIZED="$(jq -r '.initialized' <<< "${status}")"
    SEALED="$(jq -r '.sealed' <<< "${status}")"
}

initialize() {

    docker exec \
        -e VAULT_ADDR="${VAULT_ADDR}" \
        "${CONTAINER_NAME}" \
        vault operator init \
        -format=json \
        -key-shares=1 \
        -key-threshold=1 \
        > "${INIT_FILE}"

    chmod 600 "${INIT_FILE}"

    echo "Vault initialized."

}

unseal() {

    [[ -f "${INIT_FILE}" ]] || {
        echo "ERROR: ${INIT_FILE} not found." >&2
        exit 1
    }

    UNSEAL_KEY="$(jq -r '.unseal_keys_b64[0]' "${INIT_FILE}")"

    docker exec \
        -e VAULT_ADDR="${VAULT_ADDR}" \
        "${CONTAINER_NAME}" \
        vault operator unseal "${UNSEAL_KEY}" >/dev/null

    echo "Vault unsealed."

}

get_status
if [[ "$INITIALIZED" == "false" ]]; then
    initialize
fi

if [[ "$SEALED" == "true" ]]; then
    unseal
fi

ROOT_TOKEN="$(jq -r '.root_token' "${INIT_FILE}")"
echo "Root Token: ${ROOT_TOKEN}"
echo "Vault is ready."

