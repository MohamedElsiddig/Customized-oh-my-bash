cite about-completion
about-completion 'bash completion for aws command'
[[ -x "$(which aws_completer)" ]] &>/dev/null && complete -C "$(which aws_completer)" aws
