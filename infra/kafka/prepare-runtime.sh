#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
CONFIG_DIR="${RUNTIME_DIR}/config"
VOLUMES_DIR="${RUNTIME_DIR}/volumes"
CA_CERT_DIR="${SHARED_DIR}/ca-certificates"
CERT_DIR="${SERVICE_DIR}/certificates"

generate_config_files() {

    mkdir -p "${CONFIG_DIR}"

    cat > "${CONFIG_DIR}/server.properties" <<EOF
# KRaft
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@kafka:9093
controller.listener.names=CONTROLLER

# Listeners
listeners=INTERNAL://:${KAFKA_PORT},EXTERNAL://:${KAFKA_EXTERNAL_PORT},CONTROLLER://:9093
advertised.listeners=INTERNAL://kafka:${KAFKA_PORT},EXTERNAL://kafka.dev.localhost:${KAFKA_EXTERNAL_PORT}
listener.security.protocol.map=INTERNAL:SASL_SSL,EXTERNAL:SASL_SSL,CONTROLLER:SASL_SSL
inter.broker.listener.name=INTERNAL

# SSL
ssl.keystore.type=PKCS12
ssl.keystore.location=/certificates/kafka.p12
ssl.keystore.password=${KAFKA_KEYSTORE_PASSWORD}
ssl.truststore.type=PKCS12
ssl.truststore.location=/ca-certificates/truststore.p12
ssl.truststore.password=${TRUSTSTORE_PASSWORD}
ssl.client.auth=none

# SASL
sasl.enabled.mechanisms=SCRAM-SHA-512
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-512
sasl.mechanism.controller.protocol=SCRAM-SHA-512

listener.name.internal.sasl.enabled.mechanisms=SCRAM-SHA-512
listener.name.external.sasl.enabled.mechanisms=SCRAM-SHA-512
listener.name.controller.sasl.enabled.mechanisms=SCRAM-SHA-512

# JAAS
listener.name.internal.scram-sha-512.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="${KAFKA_ADMIN_USERNAME}" \
    password="${KAFKA_ADMIN_PASSWORD}";
listener.name.external.scram-sha-512.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="${KAFKA_ADMIN_USERNAME}" \
    password="${KAFKA_ADMIN_PASSWORD}";
listener.name.controller.scram-sha-512.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="${KAFKA_ADMIN_USERNAME}" \
    password="${KAFKA_ADMIN_PASSWORD}";

# Authorization
authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
allow.everyone.if.no.acl.found=false
super.users=User:${KAFKA_ADMIN_USERNAME}

# Storage
log.dirs=/var/lib/kafka/data

# Internal Topics
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

# Topic Settings
auto.create.topics.enable=false
delete.topic.enable=true

# Logging
num.partitions=3
default.replication.factor=1
min.insync.replicas=1
EOF


    cat > "${CONFIG_DIR}/client.properties" <<EOF
# Security
security.protocol=SASL_SSL

# SSL
ssl.truststore.type=PKCS12
ssl.truststore.location=/ca-certificates/truststore.p12
ssl.truststore.password=${TRUSTSTORE_PASSWORD}

# SASL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="${KAFKA_ADMIN_USERNAME}" \
    password="${KAFKA_ADMIN_PASSWORD}";
EOF

}

kafka_exec() {

    docker run --rm \
        -v "${CA_CERT_DIR}:/ca-certificates:ro" \
        -v "${CERT_DIR}:/certificates:ro" \
        -v "${CONFIG_DIR}:/config:ro" \
        -v "${VOLUMES_DIR}:/var/lib/kafka/data" \
        apache/kafka:${KAFKA_VERSION} \
        "$@"

}

format_kraft_storage() {

    kafka_exec \
        /opt/kafka/bin/kafka-storage.sh format \
        --cluster-id "${KAFKA_CLUSTER_ID}" \
        --config /config/server.properties \
        --add-scram "SCRAM-SHA-512=[name=${KAFKA_ADMIN_USERNAME},password=${KAFKA_ADMIN_PASSWORD}]"

}

generate_config_files
format_kraft_storage
