#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SHARE_DIR}/foreach-service.sh"
source "${SHARE_DIR}/set-env.sh"

CA_CERT_DIR="${SHARE_DIR}/ca-certificates"
CA_CRT_FILE="${CA_CERT_DIR}/ca.crt"
CA_KEY_FILE="${CA_CERT_DIR}/ca.key"

generate_ca_cert() {

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

generate_truststore() {

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

generate_server_cert() {

    local service=$1
    local subdomain=$2
    local service_dir=$3
    local service_cert_dir=$4

    local domain="${subdomain}.${ROOT_DOMAIN}"

    echo
    echo "# Generating cert for ${service}"

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

call_generate_keystore_script() {

    local service=$1
    local subdomain=$2
    local service_dir=$3

    local script="${service_dir}/generate-keystore.sh"
    if [[ -f "$script" ]]; then

        echo
        echo "# Generate Keystore for ${service}"

        "${script}"

    fi

}

generate_cert() {

    local service=$1
    local subdomain=$2

    local service_dir="${ROOT_DIR}/${service}"
    local service_cert_dir="${service_dir}/certificates"

    generate_server_cert "${service}" "${subdomain}" "${service_dir}" "${service_cert_dir}"
    call_generate_keystore_script "${service}" "${subdomain}" "${service_dir}"

    tree -pug "${service_cert_dir}"

}

generate_ca_cert
generate_truststore
tree -pug "$CA_CERT_DIR"

foreach_service generate_cert "$@"

echo
echo "Generate cert for all services completed."


