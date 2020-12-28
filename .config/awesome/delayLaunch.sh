#!/bin/bash
sleep 0.1
# we are using a non-interactive shell, so skip the ubuntu check
eval "$(cat ~/.bashrc | tail -n +10)"
eval "$@"
