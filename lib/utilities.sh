#!/usr/bin/env bash
#
# A collection of reusable functions.

###########################################################################
# Component-specific functions (component is either an alias, a plugin, or a
# completion).
###########################################################################

_OSH-component-help() {
  local component=$(_OSH-pluralize-component "${1}")
  local file=$(_OSH-component-cache-file ${component})
  if [[ ! -s "${file}" || -z $(find "${file}" -mmin -300) ]] ; then
    rm -f "${file}" 2>/dev/null
    local func="_OSH-${component}"
    ${func} | $(_OSH-grep) -E '   \[' | cat > ${file}
  fi
  cat "${file}"
}

_OSH-component-cache-file() {
  local component=$(_OSH-pluralize-component "${1}")
  local file="${OSH}/cache/${component}"
  [[ -f ${file} ]] || mkdir -p $(dirname ${file})
  printf "${file}"
}

_OSH-pluralize-component() {
  local component="${1}"
  local len=$(( ${#component} - 1 ))
  # pluralize component name for consistency
  [[ ${component:${len}:1} != 's' ]] && component="${component}s"
  [[ ${component} == "alias" ]] && component="aliases"
  printf ${component}
}

_OSH-clean-component-cache() {
  local component="$1"
  local cache
  local -a OSH_COMPONENTS=(aliases plugins completions)
  if [[ -z ${component} ]] ; then
    for component in "${OSH_COMPONENTS[@]}" ; do
      _OSH-clean-component-cache "${component}"
    done
  else
    cache="$(_OSH-component-cache-file ${component})"
    if [[ -f "${cache}" ]] ; then
      rm -f "${cache}"
    fi
  fi
}

###########################################################################
# Generic utilies
###########################################################################

# This function searches an array for an exact match against the term passed
# as the first argument to the function. This function exits as soon as
# a match is found.
#
# Returns:
#   0 when a match is found, otherwise 1.
#
# Examples:
#   $ declare -a fruits=(apple orange pear mandarin)
#
#   $ _OSH-array-contains-element apple "@{fruits[@]}" && echo 'contains apple'
#   contains apple
#
#   $ if $(_OSH-array-contains-element pear "${fruits[@]}"); then
#       echo "contains pear!"
#     fi
#   contains pear!
#
#
_OSH-array-contains-element() {
  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

# Dedupe a simple array of words without spaces.
_OSH-array-dedup() {
  echo "$*" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Outputs a full path of the grep found on the filesystem
_OSH-grep() {
  if [[ -z "${OSH_GREP}" ]] ; then
    export OSH_GREP="$(which egrep || which grep || '/usr/bin/grep')"
  fi
  printf "%s " "${OSH_GREP}"
}


# Returns an array of items within each compoenent.
_OSH-component-list() {
  local component="$1"
  _OSH-component-help "${component}" | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

_OSH-component-list-matching() {
  local component="$1"; shift
  local term="$1"
  _OSH-component-help "${component}" | $(_OSH-grep) -E -- "${term}" | awk '{print $1}' | sort | uniq
}

_OSH-component-list-enabled() {
  local component="$1"
  _OSH-component-help "${component}" | $(_OSH-grep) -E  '\[x\]' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

_OSH-component-list-disabled() {
  local component="$1"
  _OSH-component-help "${component}" | $(_OSH-grep) -E -v '\[x\]' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# Checks if a given item is enabled for a particular component/file-type.
# Uses the component cache if available.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _OSH-component-item-is-enabled alias git && echo "git alias is enabled"
_OSH-component-item-is-enabled() {
  local component="$1"
  local item="$2"
 _OSH-component-help "${component}" | $(_OSH-grep) -E '\[x\]' |  $(_OSH-grep) -E -q -- "^${item}\s"
}

# Checks if a given item is disabled for a particular component/file-type.
# Uses the component cache if available.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _OSH-component-item-is-disabled alias git && echo "git aliases are disabled"
_OSH-component-item-is-disabled() {
  local component="$1"
  local item="$2"
  _OSH-component-help "${component}" | $(_OSH-grep) -E -v '\[x\]' |  $(_OSH-grep) -E -q -- "^${item}\s"
}

