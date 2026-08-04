#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

CA_CERT_DIR="${SHARED_DIR}/ca-certificates"
SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${SERVICE_DIR}/certificates"

prepare_keystore() {

    openssl pkcs12 \
      -export \
      -name kafka \
      -inkey "${CERT_DIR}/kafka.key" \
      -in "${CERT_DIR}/kafka.crt" \
      -certfile "${CA_CERT_DIR}/ca.crt" \
      -out "${CERT_DIR}/kafka.p12" \
      -passout pass:"${KAFKA_KEYSTORE_PASSWORD}"

    chmod a+r "${CERT_DIR}/kafka.p12"

}

prepare_keystore
