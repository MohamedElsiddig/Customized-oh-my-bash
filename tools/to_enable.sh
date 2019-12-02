#!/bin/bash
    OSH="$HOME/.oh-my-bash"
    source "$OSH/lib/composure.sh"
    source "$OSH/lib/utilities.sh"
	cite _about _param _example _group _author _version
	source "$OSH/lib/helpers.sh"

    to_be_load_plugins=(base alias-completion)

    to_be_load_aliases=(general ls)

    to_be_load_completions=(base hints oh-my-bash reference)

    for load_plugins in ${to_be_load_plugins[@]}
        do
            oh-my-bash enable plugin $load_plugins
    done

for load_aliases in ${to_be_load_aliases[@]}
    do
        oh-my-bash enable alias $load_aliases  
done

for load_completions in ${to_be_load_completions[@]}
    do
        oh-my-bash enable completion $load_completions
done