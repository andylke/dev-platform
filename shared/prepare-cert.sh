#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SHARED_DIR}/set-env.sh"
source "${SHARED_DIR}/foreach-service.sh"

CA_CERT_DIR="${SHARED_DIR}/ca-certificates"
CA_CRT_FILE="${CA_CERT_DIR}/ca.crt"
CA_KEY_FILE="${CA_CERT_DIR}/ca.key"

prepare_server_cert() {

    local service_dir=$1
    local service=$2
    local subdomain=$3
    local service_cert_dir=$4

    local domain="${subdomain}.${ROOT_DOMAIN}"

    echo
    echo "# Preparing cert for ${service}"

    mkdir -p "$service_cert_dir"

    local key_file="${service_cert_dir}/${service}.key"
    local csr_file="${service_cert_dir}/${service}.csr"
    local crt_file="${service_cert_dir}/${service}.crt"
    local ext_file="${service_cert_dir}/${service}.ext"

    openssl genrsa \
        -out "$key_file" \
        4096

    chmod 644 "$key_file"

    openssl req \
        -new \
        -key "$key_file" \
        -out "$csr_file" \
        -subj "/C=MY/ST=Selangor/L=Petaling Jaya/O=Dev Platform/OU=Development/CN=${domain}"

    cat > "${ext_file}" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth

subjectAltName=@alt_names

[alt_names]
DNS.1=${subdomain}
DNS.3=${domain}
EOF

    openssl x509 \
        -req \
        -days 825 \
        -sha256 \
        -in "$csr_file" \
        -CA "$CA_CRT_FILE" \
        -CAkey "$CA_KEY_FILE" \
        -CAcreateserial \
        -out "$crt_file" \
        -extfile "$ext_file"

    rm \
        "$csr_file" \
        "$ext_file"
}

prepare_cert() {

    local service_dir=$1
    local service=$2
    local subdomain=$3
    local cert_dir="${service_dir}/certificates"

    if [[ -n "$subdomain" ]]; then
        prepare_server_cert "$service_dir" "$service" "$subdomain" "$cert_dir"
    fi

    local script="${service_dir}/prepare-cert.sh"
    if [[ -f "$script" ]]; then
        echo
        echo "# Calling ${script}"
        "${script}"
    fi

    tree -pug "$cert_dir"

}

foreach_service prepare_cert "$@"

echo
echo "Prepare cert for all services completed."


