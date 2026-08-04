#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SHARE_DIR}/foreach-service.sh"
source "${SHARE_DIR}/set-env.sh"

CA_CERT_DIR="${SHARE_DIR}/ca-certificates"
CA_CRT_FILE="${CA_CERT_DIR}/ca.crt"
CA_KEY_FILE="${CA_CERT_DIR}/ca.key"

prepare_ca_cert() {

    local ca_index_file="${CA_CERT_DIR}/index.txt"
    local ca_serial_file="${CA_CERT_DIR}/serial"
    local ca_cnf_file="${CA_CERT_DIR}/ca.cnf"

    mkdir -p "${CA_CERT_DIR}"

    rm -f \
      "$CA_CRT_FILE" \
      "$CA_KEY_FILE" \
      "$ca_index_file" \
      "$ca_serial_file" \
      "$ca_cnf_file"

    touch "$ca_index_file"
    echo 1000 > "$ca_serial_file"

    cat > "$ca_cnf_file" <<EOF
[req]
default_bits = 4096
default_md = sha256
prompt = no
distinguished_name = dn
x509_extensions = v3_ca

[dn]
C=MY
ST=Selangor
L=Petaling Jaya
O=Dev Platform
OU=Development
CN=Dev Platform Root CA

[v3_ca]
basicConstraints=critical,CA:true
keyUsage=critical,keyCertSign,cRLSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
EOF

    openssl genrsa \
        -out "$CA_KEY_FILE" \
        4096

    chmod 644 "$CA_KEY_FILE"

    openssl req \
        -x509 \
        -new \
        -days 3650 \
        -key "$CA_KEY_FILE" \
        -out "$CA_CRT_FILE" \
        -config "$ca_cnf_file"

    chmod 644 "$CA_CRT_FILE"

}

prepare_truststore() {

    local truststore_file="${CA_CERT_DIR}/truststore.p12"

    rm -f \
      "$truststore_file"

    keytool \
        -importcert \
        -noprompt \
        -alias dev-ca \
        -file "$CA_CRT_FILE" \
        -keystore "$truststore_file" \
        -storetype PKCS12 \
        -storepass "$TRUSTSTORE_PASSWORD"

}

prepare_ca_cert
prepare_truststore
tree -pug "$CA_CERT_DIR"

echo
echo "Prepare ca cert completed."


