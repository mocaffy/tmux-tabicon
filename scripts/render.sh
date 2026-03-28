#!/usr/bin/env bash

###############################################################################
# tmux-tabicon - A plugin for decorating tmux window tabs
#
# This script renders the tab decorations based on configuration.
# Settings are loaded in the following order (later overrides earlier):
#   Layer 0: default.conf (built-in defaults)
#   Layer 1: presets/<name>.conf (selected via @tmux-tabicon-preset)
#   Layer 2: @tmux-tabicon-* tmux options (scalar and array overrides)
###############################################################################

PLUGIN_DIR="$(cd -- "$(dirname "$0")/.." >/dev/null 2>&1 && pwd -P)"

#------------------------------------------------------------------------------
# SECTION 1: INITIALIZATION AND DATA COLLECTION
#------------------------------------------------------------------------------

base_index=$(tmux display -p "#{E:base-index}")
window_count=$(tmux list-windows | wc -l)
window_ids=($(tmux lsw | sed -e 's/:.*//g'))
session_name=$(tmux display -p "#S")

#------------------------------------------------------------------------------
# SECTION 2: CONFIGURATION LOADING
#------------------------------------------------------------------------------

# Layer 0: built-in defaults
source "$PLUGIN_DIR/default.conf"

# Layer 1: preset
preset=$(tmux show-option -gqv "@tmux-tabicon-preset" 2>/dev/null)
if [ -n "$preset" ] && [ "$preset" != "none" ]; then
    preset_file="$PLUGIN_DIR/presets/${preset}.conf"
    if [ -f "$preset_file" ]; then
        source "$preset_file"
    else
        tmux display-message "tmux-tabicon: preset '${preset}' not found"
    fi
fi

# Layer 2a: scalar tmux option overrides
load_scalar_option() {
    local tmux_opt="$1"
    local var_name="$2"
    local val
    val=$(tmux show-option -gqv "$tmux_opt" 2>/dev/null)
    if [ -n "$val" ]; then
        eval "${var_name}=\$val"
    fi
}

load_scalar_option "@tmux-tabicon-tab-title"               "tab_title"
load_scalar_option "@tmux-tabicon-tab-active-title"        "tab_active_title"
load_scalar_option "@tmux-tabicon-tab-separator"           "tab_separator"
load_scalar_option "@tmux-tabicon-style-tab"               "style_tab"
load_scalar_option "@tmux-tabicon-style-tab-icon"          "style_tab_icon"
load_scalar_option "@tmux-tabicon-style-tab-title"         "style_tab_title"
load_scalar_option "@tmux-tabicon-style-tab-active"        "style_tab_active"
load_scalar_option "@tmux-tabicon-style-tab-active-icon"   "style_tab_active_icon"
load_scalar_option "@tmux-tabicon-style-tab-active-title"  "style_tab_active_title"
load_scalar_option "@tmux-tabicon-tab-before"              "tab_before"
load_scalar_option "@tmux-tabicon-tab-before-first"        "tab_before_first"
load_scalar_option "@tmux-tabicon-tab-after"               "tab_after"
load_scalar_option "@tmux-tabicon-tab-after-last"          "tab_after_last"
load_scalar_option "@tmux-tabicon-tab-active-before"       "tab_active_before"
load_scalar_option "@tmux-tabicon-tab-active-before-first" "tab_active_before_first"
load_scalar_option "@tmux-tabicon-tab-active-after"        "tab_active_after"
load_scalar_option "@tmux-tabicon-tab-active-after-last"   "tab_active_after_last"

# Layer 2b: array tmux option overrides (| delimited)
load_array_option() {
    local tmux_opt="$1"
    local var_name="$2"
    local val
    val=$(tmux show-option -gqv "$tmux_opt" 2>/dev/null)
    if [ -n "$val" ]; then
        local IFS='|'
        eval "${var_name}=(\$val)"
    fi
}

load_array_option "@tmux-tabicon-auto-colors"    "auto_colors"
load_array_option "@tmux-tabicon-auto-icons"     "auto_icons"
load_array_option "@tmux-tabicon-manual-colors"  "manual_colors"
load_array_option "@tmux-tabicon-manual-icons"   "manual_icons"

#------------------------------------------------------------------------------
# SECTION 3: FORMAT STRING GENERATION
#------------------------------------------------------------------------------

replace_color_placeholder() {
    local input_string=$1
    echo ${input_string//\#C/$color_format}
}

create_window_status_format() {
    if [ $tab_title_format != "" ]; then
        tab_title_format=" $tab_title_format"
    fi

    local format="$default_style"
    format+="$tab_before_format$default_style"
    format+="$icon_style$icon_format$default_style"
    format+="$title_style$tab_title_format$default_style"
    format+="$tab_after_format"

    echo $format
}

create_format_string() {
    local array_name=$1
    local is_auto=$2
    local format=""

    eval "local array_length=\${#$array_name[@]}"

    if [ $array_length -gt 0 ]; then
        for ((i = 0; i < $array_length; i++)); do
            eval "local element=\${$array_name[$i]}"

            if [ "$is_auto" = true ]; then
                local is_target_format="?#{==:#{e|m|:#I,$array_length},$i}"
                format="#{$is_target_format,$element,$format}"
            else
                format="#{$element,$format}"
            fi
        done
    fi

    echo "$format"
}

icon_format=$(create_format_string "auto_icons" true)
manual_icon_format=$(create_format_string "manual_icons" false)
if [ -n "$manual_icon_format" ]; then
    icon_format="$manual_icon_format$icon_format"
fi

color_format=$(create_format_string "auto_colors" true)
manual_color_format=$(create_format_string "manual_colors" false)
if [ -n "$manual_color_format" ]; then
    color_format="$manual_color_format$color_format"
fi

is_first_format="?#{!=:#I,${window_ids[0]}}"
is_last_format="?#{!=:#I,${window_ids[$(($window_count - 1))]}}"

#------------------------------------------------------------------------------
# SECTION 4: APPLY FORMATTING TO NORMAL TABS
#------------------------------------------------------------------------------

default_style=$(replace_color_placeholder "$style_tab")
icon_style=$(replace_color_placeholder "$style_tab_icon")
title_style=$(replace_color_placeholder "$style_tab_title")

tab_before_format=$(replace_color_placeholder "#{$is_first_format,$tab_before,$tab_before_first}")
tab_after_format=$(replace_color_placeholder "#{$is_last_format,$tab_after,$tab_after_last}")
tab_title_format=$tab_title

window_status_format=$(create_window_status_format)

#------------------------------------------------------------------------------
# SECTION 5: APPLY FORMATTING TO ACTIVE TAB
#------------------------------------------------------------------------------

default_style=$(replace_color_placeholder "$style_tab_active")
icon_style=$(replace_color_placeholder "$style_tab_active_icon")
title_style=$(replace_color_placeholder "$style_tab_active_title")

tab_before_format=$(replace_color_placeholder "#{$is_first_format,$tab_active_before,$tab_active_before_first}")
tab_after_format=$(replace_color_placeholder "#{$is_last_format,$tab_active_after,$tab_active_after_last}")
tab_title_format=$tab_active_title

window_status_current_format=$(create_window_status_format)

#------------------------------------------------------------------------------
# SECTION 6: APPLY SETTINGS TO TMUX
#------------------------------------------------------------------------------

tmux set-window-option -g window-status-format ""
tmux set-window-option -g window-status-current-format ""

for id in ${window_ids[@]}; do
    tmux set-window-option -t $id window-status-format "$window_status_format"
    tmux set-window-option -t $id window-status-current-format "$window_status_current_format"
    tmux set-window-option -t $id window-status-separator "$tab_separator"
done
