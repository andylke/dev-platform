#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

build_compose_args() {

    local -n result=$1
    shift

    [[ $# -gt 0 ]] || {
        echo "Error: no groups provided." >&2
        exit 1
    }

    local root_compose_file="${ROOT_DIR}/compose.yaml"
    result=(-f "${root_compose_file}")

    local group_list=("$@")
    local group_selector

    for group_selector in "${group_list[@]}"; do

        local group="${group_selector%%/*}"
        local service_selector=""

        if [[ "$group_selector" == */* ]]; then
            service_selector="${group_selector#*/}"
        fi

        local group_dir="${ROOT_DIR}/${group}"
        local conf_file="${group_dir}/services.conf"

        [[ -f "${conf_file}" ]] || {
            echo "ERROR: ${conf_file} not found." >&2
            exit 1
        }

        local entry_list entry
        mapfile -t entry_list < "${conf_file}"

        for entry in "${entry_list[@]}"; do

            entry="${entry#"${entry%%[![:space:]]*}"}"
            [[ -z "$entry" || "$entry" == \#* ]] && continue

            local service
            read -r service _ <<< "$entry"

            if [[ -n "$service_selector" && "$service" != "$service_selector" ]]; then
                continue
            fi

            local compose_file="${group_dir}/${service}/compose.yaml"
            if [[ -f "${compose_file}" ]]; then
                result+=(-f "${compose_file}")
            fi

        done
    done

}
