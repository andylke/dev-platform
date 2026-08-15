#!/usr/bin/env bash

set -Eeuo pipefail
trap 'rc=$?; echo "ERROR: ${BASH_SOURCE[0]}:${LINENO}: ${BASH_COMMAND} (exit ${rc})" >&2' ERR

SHARED_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SHARED_DIR}/build-compose-args.sh"
source "${SHARED_DIR}/foreach-service.sh"

prepare_service() {

    local service_dir=$1

    local script="${service_dir}/prepare-service.sh"
    if [[ -f "$script" ]]; then
        echo
        echo "# Calling ${script}"
        "${script}"
        echo
    fi

}

declare -a compose_args
build_compose_args compose_args "$@"

docker compose "${compose_args[@]}" restart

sleep 5

foreach_service prepare_service "$@"

docker ps
