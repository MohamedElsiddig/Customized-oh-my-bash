#!/usr/bin/env bash
cite about-completion
about-completion 'oh-my-bash command completion'

_OSH-comp-enable-disable()
{
  local enable_disable_args="alias completion dotfile plugin"
  COMPREPLY=( $(compgen -W "${enable_disable_args}" -- ${cur}) )
}

_OSH-comp-list-available-not-enabled()
{
  subdirectory="$1"

  local available_things

  available_things=$(for f in `compgen -G "${OSH}/$subdirectory/*.sh" | sort -d`;
    do
      file_entity=$(basename $f)

      typeset enabled_component=$(command ls "${OSH}/$subdirectory/enabled/"{[0-9]*$OSH_LOAD_PRIORITY_SEPARATOR$file_entity,$file_entity} 2>/dev/null | head -1)
      typeset enabled_component_global=$(command ls "${OSH}/enabled/"[0-9]*$OSH_LOAD_PRIORITY_SEPARATOR$file_entity 2>/dev/null | head -1)

      if [ -z "$enabled_component" ] && [ -z "$enabled_component_global" ]
      then
        basename $f | sed -e 's/\(.*\)\..*\.sh/\1/g'
      fi
    done)

  COMPREPLY=( $(compgen -W "all ${available_things}" -- ${cur}) )
}

_OSH-comp-list-enabled()
{
  local subdirectory="$1"
  local suffix enabled_things

  suffix=$(echo "$subdirectory" | sed -e 's/plugins/plugin/g')

  enabled_things=$(for f in `sort -d <(compgen -G "${OSH}/$subdirectory/enabled/*.${suffix}.sh") <(compgen -G "${OSH}/enabled/*.${suffix}.sh")`;
    do
      basename $f | sed -e 's/\(.*\)\..*\.sh/\1/g' | sed -e "s/^[0-9]*---//g"
    done)

  COMPREPLY=( $(compgen -W "all ${enabled_things}" -- ${cur}) )
}

_OSH-comp-list-available()
{
  subdirectory="$1"

  local enabled_things

  enabled_things=$(for f in `compgen -G "${OSH}/$subdirectory/*.sh" | sort -d`;
    do
      basename $f | sed -e 's/\(.*\)\..*\.sh/\1/g'
    done)

  COMPREPLY=( $(compgen -W "${enabled_things}" -- ${cur}) )
}

_OSH-comp()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  chose_opt="${COMP_WORDS[1]}"
  file_type="${COMP_WORDS[2]}"
  opts="disable enable help reload search show show-enabled"
  case "${chose_opt}" in
    show)
      local show_args="aliases" "dotfiles" "completions" "plugins"
      COMPREPLY=( $(compgen -W "${show_args}" -- ${cur}) )
      return 0
      ;;
    help)
      if [ x"${prev}" == x"aliases" ]; then
        _OSH-comp-list-available aliases
        return 0
      else
        local help_args="aliases dotfiles completions plugins show-enabled"
        COMPREPLY=( $(compgen -W "${help_args}" -- ${cur}) )
        return 0
      fi
      ;;
    migrate | reload | search | update | version)
      return 0
      ;;
    enable | disable)
      if [ x"${chose_opt}" == x"enable" ];then
        suffix="available-not-enabled"
      else
        suffix="enabled"
      fi
      case "${file_type}" in
        alias)
            _OSH-comp-list-${suffix} aliases
            return 0
            ;;
        plugin)
            _OSH-comp-list-${suffix} plugins
            return 0
            ;;
        completion)
            _OSH-comp-list-${suffix} completion
            return 0
            ;;
        dotfile)
            _OSH-comp-list-${suffix} dotfile
            return 0
            ;;
        *)
            _OSH-comp-enable-disable
            return 0
            ;;
      esac
      ;;
  esac

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )

  return 0
}

# Activate completion for oh-my-bash and its common misspellings
complete -F _OSH-comp oh-my-bash
complete -F _OSH-comp ohbash
complete -F _OSH-comp ohmy
complete -F _OSH-comp mybash
complete -F _OSH-comp my-bash
complete -F _OSH-comp ohmybash
