#!/usr/bin/env bash
cite about-completion
about-completion 'npm (Node Package Manager) completion'
# npm (Node Package Manager) completion
# https://docs.npmjs.com/cli/completion

if command -v npm &>/dev/null
then
  eval "$(npm completion)"
fi
