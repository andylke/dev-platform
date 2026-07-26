#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "${SHARE_DIR}/build-compose-args.sh"

declare -a compose_args
build_compose_args compose_args "$@"

docker compose "${compose_args[@]}" down

