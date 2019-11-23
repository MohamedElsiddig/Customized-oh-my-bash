#/usr/bin/env bash
cite about-completion
about-completion 'Bash completion for `bash package manager tool "bpkg"` (https://github.com/bpkg)'

_bpkg()
{ 
   if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi

   COMPREPLY=($(compgen  -W "getdeps init install json list package show suggest term update utils" "${COMP_WORDS[1]}")) 
   
}

		complete  -F _bpkg bpkg 
