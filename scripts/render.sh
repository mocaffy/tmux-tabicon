#!/usr/bin/env bash

###############################################################################
# tmux-tabicon - A plugin for decorating tmux window tabs
# 
# This script renders the tab decorations based on configuration files.
# It applies colors, icons, and formatting to tmux window tabs.
###############################################################################

#------------------------------------------------------------------------------
# SECTION 1: INITIALIZATION AND DATA COLLECTION
#------------------------------------------------------------------------------

# Retrieve basic information from tmux
# base_index    : The starting index for window IDs
# window_count  : Total number of windows in the current session
# window_ids    : List of all window IDs in the current session
# session_name  : Name of the current tmux session
# themes_dir    : Directory containing theme configuration files
base_index=$(tmux display -p "#{E:base-index}")
window_count=$(tmux list-windows | wc -l)
window_ids=($(tmux lsw | sed -e 's/:.*//g'))
session_name=$(tmux display -p "#S")
themes_dir=$(tmux display -p "#{@tmux-tabicon-themes-dir}")

#------------------------------------------------------------------------------
# SECTION 2: CONFIGURATION LOADING
#------------------------------------------------------------------------------

# Helper function to load YAML configuration
load_yaml_config() {
    local yaml_file=$1
    local temp_bash_file=$(mktemp)
    
    if [ -f "$yaml_file" ]; then
        # Convert YAML to Bash variables
        python3 "$(dirname $0)/yaml_to_bash.py" "$yaml_file" > "$temp_bash_file"
        source "$temp_bash_file"
        rm "$temp_bash_file"
        return 0
    fi
    return 1
}

# Change to the plugin directory
cd $(dirname $0) && cd ..

# First try to load default.yml, fall back to default.conf if not found or conversion fails
if ! load_yaml_config "./default.yml"; then
    source ./default.conf
fi

# Change to the themes directory
cd $themes_dir

# Try to load normal.yml first, then fall back to normal.conf
normal_yml=$(find $themes_dir -maxdepth 1 -type f | grep "\/normal\.yml$")
normal_conf=$(find $themes_dir -maxdepth 1 -type f | grep "\/normal\.conf$")

if [ -n "$normal_yml" ]; then
    load_yaml_config "$normal_yml"
elif [ -n "$normal_conf" ]; then
    source $normal_conf
fi

# Then load session-specific configuration if it exists
# First try YAML format, then fall back to conf format
yaml_loaded=false
for file in $(\find $themes_dir -maxdepth 1 -type f | grep "\.yml$"); do
    target_session_name=${file##*/}
    target_session_name=${target_session_name%.*}
    if [ "$target_session_name" = "$session_name" ]; then
        load_yaml_config "$file"
        yaml_loaded=true
        break
    fi
done

# If no YAML config was loaded for this session, try conf format
if [ "$yaml_loaded" = false ]; then
    for file in $(\find $themes_dir -maxdepth 1 -type f | grep "\.conf$"); do
        target_session_name=${file##*/}
        target_session_name=${target_session_name%.*}
        if [ "$target_session_name" = "$session_name" ]; then
            source "$file"
            break
        fi
    done
fi

#------------------------------------------------------------------------------
# SECTION 3: FORMAT STRING GENERATION
#------------------------------------------------------------------------------

# Helper functions for format string generation

# replace_color_placeholder: Replaces #C with the actual color format
# Args:
#   $1: String containing #C placeholders
replace_color_placeholder() {
        local input_string=$1
        echo ${input_string//\#C/$color_format}
}

# create_window_status_format: Creates the complete format string for a window tab
# Uses global variables for styling components
create_window_status_format() {
        # Add space before title if title exists
        if [ $tab_title_format != "" ]; then
                tab_title_format=" $tab_title_format"
        fi
        
        # Build the complete format string by concatenating all components
        local format="$default_style"
        format+="$tab_before_format$default_style"
        format+="$icon_style$icon_format$default_style"
        format+="$title_style$tab_title_format$default_style"
        format+="$tab_after_format"
        
        echo $format
}

# create_format_string: Creates a format string for auto/manual arrays
# Args:
#   $1: Array name (auto_icons, manual_icons, auto_colors, manual_colors)
#   $2: Is this an auto array (true/false)
create_format_string() {
        local array_name=$1
        local is_auto=$2
        local format=""
        
        # Get array length using indirect reference
        eval "local array_length=\${#$array_name[@]}"
        
        if [ $array_length -gt 0 ]; then
                for ((i = 0; i < $array_length; i++)); do
                        # Get array element using indirect reference
                        eval "local element=\${$array_name[$i]}"
                        
                        if [ "$is_auto" = true ]; then
                                # For auto arrays, create format based on window index modulo array length
                                local is_target_format="?#{==:#{e|m|:#I,$array_length},$i}"
                                format="#{$is_target_format,$element,$format}"
                        else
                                # For manual arrays, just append the conditional format
                                format="#{$element,$format}"
                        fi
                done
        fi
        
        echo "$format"
}

# Generate icon format string
icon_format=$(create_format_string "auto_icons" true)
manual_icon_format=$(create_format_string "manual_icons" false)
if [ -n "$manual_icon_format" ]; then
        icon_format="$manual_icon_format$icon_format"
fi

# Generate color format string
color_format=$(create_format_string "auto_colors" true)
manual_color_format=$(create_format_string "manual_colors" false)
if [ -n "$manual_color_format" ]; then
        color_format="$manual_color_format$color_format"
fi

# Create conditional formats for first and last window detection
is_first_format="?#{!=:#I,${window_ids[0]}}"
is_last_format="?#{!=:#I,${window_ids[$(($window_count - 1))]}}"

#------------------------------------------------------------------------------
# SECTION 4: APPLY FORMATTING TO NORMAL TABS
#------------------------------------------------------------------------------

# Apply color replacements and create format for normal (inactive) tabs
default_style=$(replace_color_placeholder "$style_tab")
icon_style=$(replace_color_placeholder "$style_tab_icon")
title_style=$(replace_color_placeholder "$style_tab_title")

# Apply special formatting for first/last tabs
tab_before_format=$(replace_color_placeholder "#{$is_first_format,$tab_before,$tab_before_first}")
tab_after_format=$(replace_color_placeholder "#{$is_last_format,$tab_after,$tab_after_last}")
tab_title_format=$tab_title

# Generate the complete format string for normal tabs
window_status_format=$(create_window_status_format)

#------------------------------------------------------------------------------
# SECTION 5: APPLY FORMATTING TO ACTIVE TAB
#------------------------------------------------------------------------------

# Apply color replacements and create format for active tab
default_style=$(replace_color_placeholder "$style_tab_active")
icon_style=$(replace_color_placeholder "$style_tab_active_icon")
title_style=$(replace_color_placeholder "$style_tab_active_title")

# Apply special formatting for first/last tabs
tab_before_format=$(replace_color_placeholder "#{$is_first_format,$tab_active_before,$tab_active_before_first}")
tab_after_format=$(replace_color_placeholder "#{$is_last_format,$tab_active_after,$tab_active_after_last}")
tab_title_format=$tab_active_title

# Generate the complete format string for active tab
window_status_current_format=$(create_window_status_format)

#------------------------------------------------------------------------------
# SECTION 6: APPLY SETTINGS TO TMUX
#------------------------------------------------------------------------------

# Clear global window status formats
tmux set-window-option -g window-status-format ""
tmux set-window-option -g window-status-current-format ""

# Apply the generated formats to each window in the current session
for id in ${window_ids[@]}; do
        tmux set-window-option -t $id window-status-format "$window_status_format"
        tmux set-window-option -t $id window-status-current-format "$window_status_current_format"
        tmux set-window-option -t $id window-status-separator "$tab_separator"
done
