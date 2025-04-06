#!/usr/bin/env python3
"""
yaml_to_bash.py - Convert YAML configuration to Bash variables

This script reads a YAML configuration file for tmux-tabicon and
converts it to Bash variable declarations that can be sourced by
the render.sh script.

Usage:
    yaml_to_bash.py <yaml_file>

Output:
    Bash variable declarations are printed to stdout
"""

import sys
import os
import yaml


def flatten_dict(d, parent_key='', sep='_'):
    """Flatten a nested dictionary into a single level dictionary."""
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def yaml_to_bash(yaml_data):
    """Convert YAML data to Bash variable declarations."""
    bash_vars = []

    # Handle colors
    if 'colors' in yaml_data:
        if 'auto' in yaml_data['colors']:
            auto_colors = yaml_data['colors']['auto']
            color_strings = []
            for c in auto_colors:
                color_strings.append(f'"{c}"')
            bash_vars.append(f'auto_colors=({" ".join(color_strings)})')
        
        if 'manual' in yaml_data['colors']:
            manual_colors = []
            for item in yaml_data['colors']['manual']:
                if 'condition' in item and 'color' in item:
                    manual_colors.append(f'"?{item["condition"]},{item["color"]}"')
            bash_vars.append(f'manual_colors=({" ".join(manual_colors)})')
    
    # Handle icons
    if 'icons' in yaml_data:
        if 'auto' in yaml_data['icons']:
            auto_icons = yaml_data['icons']['auto']
            icon_strings = []
            for i in auto_icons:
                icon_strings.append(f'"{i}"')
            bash_vars.append(f'auto_icons=({" ".join(icon_strings)})')
        
        if 'manual' in yaml_data['icons']:
            manual_icons = []
            for item in yaml_data['icons']['manual']:
                if 'condition' in item and 'icon' in item:
                    manual_icons.append(f'"?{item["condition"]},{item["icon"]}"')
            bash_vars.append(f'manual_icons=({" ".join(manual_icons)})')
    
    # Handle normal tab settings
    if 'normal_tab' in yaml_data:
        nt = yaml_data['normal_tab']
        
        if 'title' in nt:
            bash_vars.append(f'tab_title="{nt["title"]}"')
        
        if 'formatting' in nt:
            fmt = nt['formatting']
            if 'before_first' in fmt:
                bash_vars.append(f'tab_before_first="{fmt["before_first"]}"')
            if 'before' in fmt:
                bash_vars.append(f'tab_before="{fmt["before"]}"')
            if 'after' in fmt:
                bash_vars.append(f'tab_after="{fmt["after"]}"')
            if 'after_last' in fmt:
                bash_vars.append(f'tab_after_last="{fmt["after_last"]}"')
        
        if 'style' in nt:
            style = nt['style']
            if 'base' in style:
                bash_vars.append(f'style_tab="{style["base"]}"')
            if 'icon' in style:
                bash_vars.append(f'style_tab_icon="{style["icon"]}"')
            if 'title' in style:
                bash_vars.append(f'style_tab_title="{style["title"]}"')
    
    # Handle active tab settings
    if 'active_tab' in yaml_data:
        at = yaml_data['active_tab']
        
        if 'title' in at:
            bash_vars.append(f'tab_active_title="{at["title"]}"')
        
        if 'formatting' in at:
            fmt = at['formatting']
            if 'before_first' in fmt:
                bash_vars.append(f'tab_active_before_first="{fmt["before_first"]}"')
            if 'before' in fmt:
                bash_vars.append(f'tab_active_before="{fmt["before"]}"')
            if 'after' in fmt:
                bash_vars.append(f'tab_active_after="{fmt["after"]}"')
            if 'after_last' in fmt:
                bash_vars.append(f'tab_active_after_last="{fmt["after_last"]}"')
        
        if 'style' in at:
            style = at['style']
            if 'base' in style:
                bash_vars.append(f'style_tab_active="{style["base"]}"')
            if 'icon' in style:
                bash_vars.append(f'style_tab_active_icon="{style["icon"]}"')
            if 'title' in style:
                bash_vars.append(f'style_tab_active_title="{style["title"]}"')
    
    # Handle separator
    if 'separator' in yaml_data:
        bash_vars.append(f'tab_separator="{yaml_data["separator"]}"')
    
    return '\n'.join(bash_vars)


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <yaml_file>", file=sys.stderr)
        sys.exit(1)
    
    yaml_file = sys.argv[1]
    
    if not os.path.exists(yaml_file):
        print(f"Error: File '{yaml_file}' not found", file=sys.stderr)
        sys.exit(1)
    
    try:
        with open(yaml_file, 'r') as f:
            yaml_data = yaml.safe_load(f)
        
        bash_vars = yaml_to_bash(yaml_data)
        print(bash_vars)
    
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()