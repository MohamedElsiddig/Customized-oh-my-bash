cite about-plugin
about-plugin 'Ubuntu like command-not-found featrue for arch based distros'

# Print to stderr
alias _cnf_print='echo -e 1>&2'

pacman_files_command(){
    local CMD=$1
    local VERSION=$(pacman -Q pacman | awk -F[\ -] '{print $2}')
    if [[ $(vercmp "$VERSION" "5.2.0") -ge 0 ]]
    then
        local ARGS="-Fq"
    else
        local ARGS="Foq"
    fi
    pacman $ARGS /usr/bin/$CMD 2> /dev/null
}

# Parse options
for opt in $*
do
    case $opt in
        noprompt) cnf_noprompt=1 ;;
        su) cnf_force_su=1 ;;
        quiet) cnf_verbose=0 ;;
        *) _cnf_print "find-the-command: unknown option: $opt"
    esac
done

# Don't show pre-search warning if 'quiet' option is not set
if [[ $cnf_verbose != 0 ]]
then
    _cnf_pre_search_warn(){
        _cnf_print "find-the-command: \"$CMD\" is not found locally, searching in repositories..." 
    }
else
    _pre_search_warn(){ : Do nothing; }
fi

# Without installation prompt
if [[ $cnf_noprompt == 1 ]]
then
    command_not_found_handle() {
        local CMD=$1
        _cnf_pre_search_warn
        local PKGS=$(pacman_files_command $CMD)
        case $(echo $PKGS | wc -w) in
            0) _cnf_print "$0: $CMD: command not found"
                return 127 ;;
            1) _cnf_print "\"$CMD\" may be found in package \"$PKGS\"" ;;
            *)
                local PKG
                _cnf_print "\"$CMD\" may be found in the following packages:"
                for PKG in `echo -n $PKGS`
                do
                _cnf_print "\t$PKG"
                done
        esac
    }
else
# With installation prompt (default)
    if [[ $EUID == 0 ]]
    then _cnf_asroot(){ $*; }
    else
        if [[ $cnf_force_su == 1 ]]
        then _cnf_asroot() { su -c "$*"; }
        else _cnf_asroot() { sudo $*; }
        fi
    fi
    command_not_found_handle() {
        local CMD=$1
        _cnf_pre_search_warn
        local PKGS=$(pacman_files_command $CMD)
        case $(echo $PKGS | wc -w) in
            0) _cnf_print "$0: $CMD: command not found"
                return 127 ;;
            1) local ACT PS3="Action (0 to abort): "
                _cnf_print "\n\"$CMD\" may be found in package \"$PKGS\"\n"
                _cnf_print "What would you like to do? "
                select ACT in 'install' 'info' 'list files' 'list files (paged)'
                do
                break
                done
                case $ACT in
                    install) _cnf_asroot pacman -S $PKGS ;;
                    info) pacman -Si $PKGS ;;
                    'list files') pacman -Flq $PKGS ;;
                    'list files (paged)') [[ -z $PAGER ]] && local PAGER=less
                        pacman -Flq $PKGS | $PAGER ;;
                    *) _cnf_print
                        return 127;;
                esac ;;
                *) local PKG PS3="$(echo -en "\nSelect a number of package to install (0 to abort):")" 
                    _cnf_print "\"$CMD\" may be found in the following packages:\n"
                    select PKG in `echo -n $PKGS`
                    do
                    break
                    done
                    [[ -n $PKG ]] && _cnf_asroot pacman -S $PKG || return 127 ;;
        esac
    }
fi

# Clean up environment
unset opt cnf_force_su cnf_noprompt cnf_verbose

