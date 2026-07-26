#!/usr/bin/env bash

foreach_service() {

    local service_conf_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/service.conf"
    local entry_list=()
    local entry

    local callback="$1"
    shift

    if [[ $# -gt 0 ]]; then
        entry_list=("$@")
    else
        mapfile -t entry_list < "${service_conf_file}"
    fi

    for entry in "${entry_list[@]}"; do

        [[ -z "$entry" || "$entry" == \#* ]] && continue

        local service subdomain
        read -r service subdomain <<< "$entry"

        [[ -n "$subdomain" ]] || subdomain="$service"

        "$callback" "$service" "$subdomain"

    done
}
