#!/bin/zsh
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/scripts/render.sh"

tmux set-hook -g session-created "ru $SCRIPT_PATH"
tmux set-hook -g after-new-window "ru $SCRIPT_PATH"
tmux set-hook -g pane-exited "ru $SCRIPT_PATH"

tmux bind-key "t" "ru $SCRIPT_PATH"
