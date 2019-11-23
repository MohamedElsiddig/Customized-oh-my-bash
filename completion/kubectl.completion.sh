#!/usr/bin/env bash

# kubectl (Kubernetes CLI) completion
cite about-completion
about-completion 'Kubernetes CLI completion'

if command -v kubectl &>/dev/null
then
  eval "$(kubectl completion bash)"
fi
