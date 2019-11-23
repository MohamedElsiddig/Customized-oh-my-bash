cite about-plugin
about-plugin '`thefuck` Magnificent app which corrects your previous console command when pressing alt + f'

if ! _command_exists thefuck ; then
    echo 'thefuck is not installed, you should "pip install thefuck" or "brew install thefuck" first.'
    echo 'See https://github.com/nvbn/thefuck#installation'
    return 1
fi

# Register alias
eval "$(thefuck --alias)"

fuck-command-line() {
    local FUCK="$(THEFUCK_REQUIRE_CONFIRMATION=0 thefuck $(fc -ln -1 | tail -n 1) 2> /dev/null)"
    [[ -z $FUCK ]] && echo -n -e "\a" && return
    READLINE_LINE=$FUCK
    
}
fuck-command-line
# Defined shortcut keys: alt + f
bind -x '"\C-[f": "fuck-command-line"' 
