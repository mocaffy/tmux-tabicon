#!/usr/bin/env bash

###############################################################################
# tmux-tabicon - A plugin for decorating tmux window tabs
#
# This is the main plugin script that sets up hooks to trigger the rendering
# of tab decorations when tmux events occur.
###############################################################################

# Get the absolute path to the render script
SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)/scripts/render.sh"

# Set up tmux hooks to trigger tab rendering on various events:
# - When a new session is created
tmux set-hook -g session-created "ru $SCRIPT_PATH"
# - When a new window is created
tmux set-hook -g after-new-window "ru $SCRIPT_PATH"
# - When a pane is closed
tmux set-hook -g pane-exited "ru $SCRIPT_PATH"

# Bind the 'r' key to manually trigger tab rendering
# This allows users to refresh tab decorations on demand
tmux bind-key "r" "ru $SCRIPT_PATH"
