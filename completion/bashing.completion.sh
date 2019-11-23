#/usr/bin/env bash
cite about-completion
about-completion 'Bash completion for Bashing tool (https://github.com/xsc/bashing)'

_bashing()
{ 
   if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi

   COMPREPLY=($(compgen  -W "install new new.task remote run help clean uberbash version" "${COMP_WORDS[1]}")) 
   
}

		complete  -F _bashing bashing 
