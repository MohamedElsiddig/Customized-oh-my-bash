#!/bin/sh
pushd "${OSH}" >/dev/null || exit 1

# TODO: Add debugging output

if [ "$1" != "skip" ] && [ -d "./enabled" ]; then
  _OSH_config_type=""
  if [[ "${1}" =~ ^(alias|completion|dotfile|plugin)$ ]]; then
    _OSH_config_type=$1
  fi
  for _OSH_config_file in $(sort <(compgen -G "./enabled/*${_OSH_config_type}.sh")); do
    if [ -e "${_OSH_config_file}" ]; then
      name_and_topic="$(basename --suffix=.sh "${_OSH_config_file}" \
        | sed --regexp-extended 's/[[:digit:]]{1,3}-{3}//')"
      name="$(echo "${name_and_topic}" | cut --delimiter=. --fields=1)"
      topic="$(echo "${name_and_topic}" | cut --delimiter=. --fields=2)"
      print_doing "${topic}/${name}" > /dev/null 2>&1

      # shellcheck source=/dev/null
      if source $_OSH_config_file
      then
        print_done "${topic}/${name}" 
      else
        print_not_done "${topic}/${name}" ${?}
      fi

      unset name name_and_topic topic
    else
      echo "Unable to read ${_OSH_config_file}" > /dev/stderr
    fi
  done >| $OSH/log/bash-startup.log
fi


if [ ! -z "${2}" ] && [[ "${2}" =~ ^(aliases|dotfile|completion|plugins)$ ]] && [ -d "${2}/enabled" ]; then
  # TODO: We should warn users they're using legacy enabling
  for _OSH_config_file in $(sort <(compgen -G "./${2}/enabled/*.sh")); do
    if [ -e "$_OSH_config_file" ]; then
      # shellcheck source=/dev/null
      source "$_OSH_config_file"
    else
      echo "Unable to locate ${_OSH_config_file}" > /dev/stderr
    fi
  done
fi

unset _OSH_config_file
unset _OSH_config_type
popd >/dev/null || exit 1
