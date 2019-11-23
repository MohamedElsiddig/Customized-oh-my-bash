#!/bin/bash
pushd "${OSH}" >/dev/null || exit 1

# TODO: Add debugging output

if [ "$1" != "skip" ] && [ -d "./enabled" ]; then
  _OSH_config_type=""
  if [[ "${1}" =~ ^(alias|completion|plugin)$ ]]; then
   _OSH_config_type=$1
  fi
  for _OSH_config_type in $(sort <(compgen -G "./enabled/*${_OSH_config_type}.sh")); do
    if [ -e "${_OSH_config_type}" ]; then
      # shellcheck source=/dev/null
      source $_OSH_config_type
    else
      echo "Unable to read ${_OSH_config_type}" > /dev/stderr
    fi
  done
fi


if [ ! -z "${2}" ] && [[ "${2}" =~ ^(aliases|completion|plugins)$ ]] && [ -d "${2}/enabled" ]; then
  # TODO: We should warn users they're using legacy enabling
  for _OSH_config_type in $(sort <(compgen -G "./${2}/enabled/*.sh")); do
    if [ -e "$_OSH_config_type" ]; then
      # shellcheck source=/dev/null
      source "$_OSH_config_type"
    else
      echo "Unable to locate ${_OSH_config_type}" > /dev/stderr
    fi
  done
fi

unset _OSH_config_type
unset _OSH_config_type
popd >/dev/null || exit 1
