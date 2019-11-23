#!/usr/bin/env bash
cite about-completion
about-completion 'nvm (Node Version Manager) completion'

# nvm (Node Version Manager) completion

if [ "$NVM_DIR" ] && [ -r "$NVM_DIR"/bash_completion ];
then
  . "$NVM_DIR"/bash_completion
fi
