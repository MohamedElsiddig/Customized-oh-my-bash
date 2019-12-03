#!/usr/bin/env bash

OSH_LOAD_PRIORITY_DEFAULT_ALIAS=${OSH_LOAD_PRIORITY_DEFAULT_ALIAS:-150}
OSH_LOAD_PRIORITY_DEFAULT_PLUGIN=${OSH_LOAD_PRIORITY_DEFAULT_PLUGIN:-250}
OSH_LOAD_PRIORITY_DEFAULT_COMPLETION=${OSH_LOAD_PRIORITY_DEFAULT_COMPLETION:-350}
OSH_LOAD_PRIORITY_SEPARATOR="---"
source "${OSH}/themes/colours.theme.sh"

function _command_exists ()
{
  _about 'checks for existence of a command'
  _param '1: command to check'
  _example '$ _command_exists ls && echo exists'
  _group 'lib'
  type "$1" &> /dev/null ;
}

function _make_reload_alias() {
  echo "source \${OSH}/scripts/reloader.sh ${1} ${2}"
}

# Alias for reloading aliases
# shellcheck disable=SC2139
alias reload_aliases="$(_make_reload_alias alias aliases)"

# Alias for reloading auto-completion
# shellcheck disable=SC2139
alias reload_completion="$(_make_reload_alias completion completions)"

# Alias for reloading plugins
# shellcheck disable=SC2139
alias reload_plugins="$(_make_reload_alias plugin plugins)"

oh-my-bash ()
{
    about 'oh-my-bash help and maintenance'
    param '1: verb [one of: help | show | enable | disable | search | reload | show-enabled ] '
    param '2: component type [one of: alias(es) | completion(s) | plugin(s) ] or search term(s)'
    param '3: specific component [optional]'
    example '$ oh-my-bash show plugins'
    example '$ oh-my-bash help aliases'
    example '$ oh-my-bash enable plugin git [tmux]...'
    example '$ oh-my-bash disable alias hg [tmux]...'
    example '$ oh-my-bash search [-|@]term1 [-|@]term2 ... [ -e/--enable ] [ -d/--disable ] [ -r/--refresh ] [ -c/--no-color ]'
    example '$ oh-my-bash reload'
    example '$ oh-my-bash show-enabled'
    typeset verb=${1:-}
    shift
    typeset component=${1:-}
    shift
    typeset func

    case $verb in
      show)
        func=_OSH-$component;;
      enable)
        func=_enable-$component;;
      disable)
        func=_disable-$component;;
      help)
        func=_help-$component;;
      search)
        _OSH-search $component "$@"
        return;;
      reload)
        func=_OSH-reload;;
      show-enabled)
        func=_OSH-show-enabled ;;
      *)
        reference oh-my-bash
        return;;
    esac

    # pluralize component if necessary
    if ! _is_function $func; then
        if _is_function ${func}s; then
            func=${func}s
        else
            if _is_function ${func}es; then
                func=${func}es
            else
                echo "oops! $component is not a valid option!"
                reference oh-my-bash
                return
            fi
        fi
    fi

    if [ x"$verb" == x"enable" ] || [ x"$verb" == x"disable" ]; then
        # Automatically run a migration if required

        for arg in "$@"
        do
            $func $arg
        done
    else
        $func "$@"
    fi
}

_is_function ()
{
    _about 'sets $? to true if parameter is the name of a function'
    _param '1: name of alleged function'
    _group 'lib'
    [ -n "$(LANG=C type -t $1 2>/dev/null | grep 'function')" ]
}

_OSH-aliases ()
{
    _about 'summarizes available oh-my-bash aliases'
    _group 'lib'

    _OSH-describe "aliases" "an" "alias" "Alias"
}

_OSH-completions ()
{
    _about 'summarizes available oh-my-bash completions'
    _group 'lib'

    _OSH-describe "completion" "a" "completion" "Completion"
}

_OSH-plugins ()
{
    _about 'summarizes available oh-my-bash plugins'
    _group 'lib'

    _OSH-describe "plugins" "a" "plugin" "Plugin"
}

_OSH-reload() {
  _about 'reloads a profile file'
  _group 'lib'

  pushd "${OSH}" &> /dev/null || return

  case $OSTYPE in
    darwin*)
      source ~/.bash_profile
      ;;
    *)
      source ~/.bashrc
      ;;
  esac

  popd &> /dev/null || return
}

_OSH-describe ()
{
    _about 'summarizes available oh-my-bash components'
    _param '1: subdirectory'
    _param '2: preposition'
    _param '3: file_type'
    _param '4: column_header'
    _example '$ _OSH-describe "plugins" "a" "plugin" "Plugin"'

    subdirectory="$1"
    preposition="$2"
    file_type="$3"
    column_header="$4"
    
    
    typeset f
    typeset enabled
    for feature_name in "$OSH/$subdirectory/"
   	do 
    	######################
 for i in "$feature_name"
 	do
   echo -e ${echo_bold_green} && printf "%-20s%-10s%s\n" "$column_header" 'Enabled?' 'Description' && echo -e ${echo_normal}
    for f in "$i"*.sh
    do
        # Check for both the old format without the load priority, and the extended format with the priority
        declare enabled_files enabled_file
        enabled_file=$(basename  $f)
        enabled_files=$(sort <(compgen -G "${OSH}/enabled/*$OSH_LOAD_PRIORITY_SEPARATOR${enabled_file}") <(compgen -G "${OSH}/$subdirectory/enabled/${enabled_file}") <(compgen -G "${OSH}/$subdirectory/enabled/*$OSH_LOAD_PRIORITY_SEPARATOR${enabled_file}") | wc -l)

        if [ $enabled_files -gt 0 ]; then
            enabled="x"
        else
            enabled=' '
        fi
        printf "%-20s%-10s%s\n" "$(basename $f | sed -e 's/\(.*\)\..*\.sh/\1/g')" "  [$enabled]" "$(cat $f | metafor about-$file_type)"
    done
done
    done
    printf '\n%s\n' "to enable $preposition $file_type, do:"
    printf '%s\n' "$ oh-my-bash enable $file_type  <$file_type name> [$file_type name]... -or- $ oh-my-bash enable $file_type all"
    printf '\n%s\n' "to disable $preposition $file_type, do:"
    printf '%s\n' "$ oh-my-bash disable $file_type <$file_type name> [$file_type name]... -or- $ oh-my-bash disable $file_type all"
}

_disable-plugin ()
{
    _about 'disables oh-my-bash plugin'
    _param '1: plugin name'
    _example '$ disable-plugin rvm'
    _group 'lib'

    _disable-thing "plugins" "plugin" $1
}

_disable-alias ()
{
    _about 'disables oh-my-bash alias'
    _param '1: alias name'
    _example '$ disable-alias git'
    _group 'lib'

    _disable-thing "aliases" "alias" $1
}

_disable-completion ()
{
    _about 'disables oh-my-bash completion'
    _param '1: completion name'
    _example '$ disable-completion git'
    _group 'lib'

    _disable-thing "completion" "completion" $1
}

_disable-thing ()
{
    _about 'disables a oh-my-bash component'
    _param '1: subdirectory'
    _param '2: file_type'
    _param '3: file_entity'
    _example '$ _disable-thing "plugins" "plugin" "ssh"'

    subdirectory="$1"
    file_type="$2"
    file_entity="$3"

    if [ -z "$file_entity" ]; then
        reference "disable-$file_type"
        return
    fi

    typeset f suffix
    suffix=$(echo "$subdirectory" | sed -e 's/plugins/plugin/g')

    if [ "$file_entity" = "all" ]; then
        # Disable everything that's using the old structure
        for f in `compgen -G "${OSH}/$subdirectory/enabled/*.${suffix}.sh"`
        do
          rm "$f"
        done

        # Disable everything in the global "enabled" directory
        for f in `compgen -G "${OSH}/enabled/*.${suffix}.sh"`
        do
          rm "$f"
        done
    else
        typeset plugin_global=$(command ls $ "${OSH}/enabled/"[0-9]*$OHS_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.sh 2>/dev/null | head -1)
        if [ -z "$plugin_global" ]; then
          # Use a glob to search for both possible patterns
          # 250---node.plugin.bash
          # node.plugin.bash
          # Either one will be matched by this glob
          typeset plugin=$(command ls $ "${OSH}/$subdirectory/enabled/"{[0-9]*$OSH_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.sh,$file_entity.$suffix.sh} 2>/dev/null | head -1)
          if [ -z "$plugin" ]; then
              echo ""
              echo -e `printf '%s\n' "${echo_bold_red} [ X ]${echo_normal} Sorry,${echo_bold_cyan} '$file_entity'${echo_normal} does not appear to be an enabled $file_type."`
              return
          fi
          rm "${OSH}/$subdirectory/enabled/$(basename $plugin)"
        else
          rm "${OSH}/enabled/$(basename $plugin_global)"
        fi
        
    fi

   _OSH-clean-component-cache "${file_type}"
   echo ""
		echo -e `printf '%s\n' "${echo_bold_green} [ ✔ ] ${echo_normal}${echo_bold_cyan}'$file_entity'${echo_normal} ${file_type} disabled."`
    if [[ -z "$OSH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
        exec ${0/-/}
    fi

    
}

_enable-plugin ()
{
    _about 'enables oh-my-bash plugin'
    _param '1: plugin name'
    _example '$ enable-plugin rvm'
    _group 'lib'

    _enable-thing "plugins" "plugin" $1 $OSH_LOAD_PRIORITY_DEFAULT_PLUGIN
}

_enable-alias ()
{
    _about 'enables oh-my-bash alias'
    _param '1: alias name'
    _example '$ enable-alias git'
    _group 'lib'

    _enable-thing "aliases" "alias" $1 $OSH_LOAD_PRIORITY_DEFAULT_ALIAS
}

_enable-completion ()
{
    _about 'enables oh-my-bash completion'
    _param '1: completion name'
    _example '$ enable-completion git'
    _group 'lib'

    _enable-thing "completion" "completion" $1 $OSH_LOAD_PRIORITY_DEFAULT_COMPLETION
}

_enable-thing ()
{
    cite _about _param _example
    _about 'enables a oh-my-bash component'
    _param '1: subdirectory'
    _param '2: file_type'
    _param '3: file_entity'
    _param '4: load priority'
    _example '$ _enable-thing "plugins" "plugin" "ssh" "150"'

    subdirectory="$1"
    file_type="$2"
    file_entity="$3"
    load_priority="$4"

    if [ -z "$file_entity" ]; then
        reference "enable-$file_type"
        return
    fi

    if [ "$file_entity" = "all" ]; then
        typeset f $file_type
        for f in "${OSH}/$subdirectory/"*.sh
        do
            to_enable=$(basename $f .$file_type.sh)
            if [ "$file_type" = "alias" ]; then
              to_enable=$(basename $f ".aliases.sh")
            fi
            _enable-thing $subdirectory $file_type $to_enable $load_priority
        done
    else
        typeset to_enable=$(command ls "${OSH}/$subdirectory/"$file_entity.*sh 2>/dev/null | head -1)
        if [ -z "$to_enable" ]; then
        echo ""
            echo -e `printf '%s\n' "${echo_bold_red} [ X ]${echo_normal} Sorry, ${echo_bold_cyan}'$file_entity'${echo_normal} does not appear to be an available $file_type."`
            return
        fi

        to_enable=$(basename $to_enable)
        # Check for existence of the file using a wildcard, since we don't know which priority might have been used when enabling it.
        typeset enabled_plugin=$(command ls "${OSH}/$subdirectory/enabled/"{[0-9][0-9][0-9]$OSH_LOAD_PRIORITY_SEPARATOR$to_enable,$to_enable} 2>/dev/null | head -1)
        if [ ! -z "$enabled_plugin" ] ; then
          printf '%s\n' "$file_entity is already enabled."
          return
        fi

        typeset enabled_plugin_global=$(command compgen -G "${OSH}/enabled/[0-9][0-9][0-9]$OSH_LOAD_PRIORITY_SEPARATOR$to_enable" 2>/dev/null | head -1)
        if [ ! -z "$enabled_plugin_global" ] ; then
        echo ""
        echo -e  `printf '%s\n' "${echo_bold_yellow} [ ! ] ${echo_bold_cyan}'$file_entity'${echo_normal} ${file_type} is already enabled."`
          return
        fi

        mkdir -p "${OSH}/enabled"

        # Load the priority from the file if it present there
        declare local_file_priority use_load_priority
        local_file_priority=$(grep -E "^# OSH_LOAD_PRIORITY:" "${OSH}/$subdirectory/$to_enable" | awk -F': ' '{ print $2 }')
        use_load_priority=${local_file_priority:-$load_priority}

        ln -s ../$subdirectory/$to_enable "${OSH}/enabled/${use_load_priority}${OSH_LOAD_PRIORITY_SEPARATOR}${to_enable}"
    fi

  _OSH-clean-component-cache "${file_type}"
    echo ""
    echo -e `printf '%s\n' "${echo_bold_green} [ ✔ ]${echo_normal} ${echo_bold_cyan}'$file_entity'${echo_normal} ${file_type} enabled with priority $use_load_priority."`

    if [[ ${file_type} == "plugin" ]]
      then
            new_to_enable=${to_enable%%.plugin.sh}
            _OSH-auto-enabling-completions $new_to_enable
    fi

    if [[ -n "OSH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
        exec ${0/-/}
    fi

   
}

_help-completions()
{
  _about 'summarize all completions available in oh-my-bash'
  _group 'lib'

  _OSH-completions
}

_help-aliases()
{
    _about 'shows help for all aliases, or a specific alias group'
    _param '1: optional alias group'
    _example '$ alias-help'
    _example '$ alias-help git'

    if [ -n "$1" ]; then
        case $1 in
            custom)
                alias_path='$OSH/custom/aliases/custom.aliases.sh'
            ;;
            *)
                alias_path="$1.aliases.sh"
            ;;
        esac
        cat "${OSH}/aliases/$alias_path" | metafor alias | sed "s/$/'/"
    else
        typeset f

        for f in `sort <(compgen -G "${OSH}/aliases/enabled/*") <(compgen -G "${OSH}/enabled/*.aliases.sh")`
        do
            _help-list-aliases $f
        done

        if [ -e "${OSH}/custom/aliases/custom.aliases.sh" ]; then
          _help-list-aliases "${OSH}/aliases/custom.aliases.sh"
        fi
    fi
}

_help-list-aliases ()
{
    typeset file=$(basename $1 | sed -e 's/[0-9]*[-]*\(.*\)\.aliases\.sh/\1/g')
    printf '\n\n%s:\n' "${file}"
    # metafor() strips trailing quotes, restore them with sed..
    cat $1 | metafor alias | sed "s/$/'/"
}
_help-show-enabled()
{
  _about 'Summarize all enabled features in oh-my-bash framework'
    _group 'lib'
    echo 'Summarize all enabled features in oh-my-bash framework'
}
_help-plugins()
{
    _about 'summarize all functions defined by enabled oh-my-bash plugins'
    _group 'lib'

    # display a brief progress message...
    printf '%s' 'please wait, building help...'
    typeset grouplist=$(mktemp -t grouplist.XXXXXX)
    typeset func
    for func in $(typeset_functions)
    do
        typeset group="$(typeset -f $func | metafor group)"
        if [ -z "$group" ]; then
            group='misc'
        fi
        typeset about="$(typeset -f $func | metafor about)"
        letterpress "$about" $func >> $grouplist.$group
        echo $grouplist.$group >> $grouplist
    done
    # clear progress message
    printf '\r%s\n' '                              '
    typeset group
    typeset gfile
    for gfile in $(cat $grouplist | sort | uniq)
    do
        printf '%s\n' "${gfile##*.}:"
        cat $gfile
        printf '\n'
        rm $gfile 2> /dev/null
    done | less
    rm $grouplist 2> /dev/null
}


_OSH-show-enabled()
{

  feature=("aliases" "plugins" "completion")
    printf '%s' 'please wait, Getting enabled features...' && sleep 3
    printf '%s\n\n'  
    for i in ${feature[@]} 
      do
        sleep 1
        echo -e "\t" -------------${echo_bold_green} Enabled $i ${echo_normal}------------- 
        sleep 1
        echo ""
        _OSH-component-help "$i" | $(_OSH-grep) -E  '\[x\]'
        _OSH-clean-component-cache "${i}"

        echo ""
    done 

}

function _OSH-auto-enabling-completions()
{
  
  enabled_elements=`_OSH-component-help "completion" | awk '{print $1}' | grep "^${new_to_enable}$" | uniq | sort | tr '\n' ' '`
  for is_enabed in ${enabled_elements[@]}
    do
        _OSH-component-item-is-enabled completion ${is_enabed}
        if [[ "$?" != "0" ]] && [[ "${AUTO_ENABLING}" == "enable" ]] 
          then
            source "${OSH}/themes/colours.theme.sh"
            source "${OSH}/themes/base.theme.sh"
            echo ""
            echo -e "$echo_bold_green Auto enabling ${new_to_enable} plugin completion${echo_normal}"
            sleep 1
            _enable-completion ${is_enabed}
            exec ${0/-/}


fi
  done
}

all_groups ()
{
    about 'displays all unique metadata groups'
    group 'lib'

    typeset func
    typeset file=$(mktemp -t composure.XXXX)
    for func in $(typeset_functions)
    do
        typeset -f $func | metafor group >> $file
    done
    cat $file | sort | uniq
    rm $file
}

if ! type pathmunge > /dev/null 2>&1
then
  function pathmunge () {
    about 'prevent duplicate directories in you PATH variable'
    group 'helpers'
    example 'pathmunge /path/to/dir is equivalent to PATH=/path/to/dir:$PATH'
    example 'pathmunge /path/to/dir after is equivalent to PATH=$PATH:/path/to/dir'

    if ! [[ $PATH =~ (^|:)$1($|:) ]] ; then
      if [ "$2" = "after" ] ; then
        export PATH=$PATH:$1
      else
        export PATH=$1:$PATH
      fi
    fi
  }
fi
