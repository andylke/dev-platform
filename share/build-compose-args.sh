#!/usr/bin/env bash

set -euo pipefail

build_compose_args() {

    local -n result=$1
    shift

    local root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local root_compose_file="${root_dir}/compose.yaml"

    local service_conf_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/service.conf"

    local entry_list=()
    local entry

    if [[ $# -gt 0 ]]; then
        entry_list=("$@")
    else
        mapfile -t entry_list < "${service_conf_file}"
    fi

    result=(-f "${root_compose_file}")

    for entry in "${entry_list[@]}"; do

        [[ -z "$entry" || "$entry" == \#* ]] && continue

        local service subdomain
        read -r service subdomain <<< "$entry"

        local compose_file="${root_dir}/${service}/compose.yaml"

        if [[ -f "${compose_file}" ]]; then
            result+=(-f "${compose_file}")
        fi

    done

}
