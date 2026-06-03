#!/bin/bash

set -o pipefail

home_scripts_repo_root() {
  local source_dir
  source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  (cd "$source_dir/../.." && pwd)
}

home_scripts_load_config() {
  local repo_root config_file
  repo_root="$(home_scripts_repo_root)"

  for config_file in \
    "${HOME_NETWORK_CONFIG:-}" \
    "$repo_root/config/home_network.conf" \
    "/etc/home-scripts/home_network.conf"; do
    if [ -n "$config_file" ] && [ -r "$config_file" ]; then
      # shellcheck source=/dev/null
      source "$config_file"
      return 0
    fi
  done

  return 0
}

home_scripts_data_dir() {
  local repo_root
  repo_root="$(home_scripts_repo_root)"
  echo "${HOME_SCRIPTS_DATA_DIR:-$repo_root/data}"
}

home_scripts_require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    return 1
  fi
}

home_scripts_detect_subnets() {
  home_scripts_require_command ip || return 1
  ip -o -f inet route show scope link | awk '$1 != "default" { print $1 }' | sort -u
}

home_scripts_get_subnets() {
  home_scripts_load_config

  if [ "$#" -gt 0 ]; then
    printf '%s\n' "$@"
    return 0
  fi

  if declare -p HOME_NETWORK_SUBNETS >/dev/null 2>&1 && [ "${#HOME_NETWORK_SUBNETS[@]}" -gt 0 ]; then
    printf '%s\n' "${HOME_NETWORK_SUBNETS[@]}"
    return 0
  fi

  home_scripts_detect_subnets
}
