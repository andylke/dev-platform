#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SHARED_DIR}/build-compose-args.sh"

declare -a compose_args
build_compose_args compose_args "$@"

docker compose "${compose_args[@]}" down

