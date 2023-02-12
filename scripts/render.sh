#!/usr/bin/env bash

cd $(dirname $0) && cd ..
source ./default.conf

base_index=$(tmux display -p "#{E:base-index}")
window_count=$(tmux list-windows | wc -l)
window_ids=($(tmux lsw | sed -e 's/:.*//g'))
session_name=$(tmux display -p "#S")
themes_dir=$(tmux display -p "#{@tmux-tabicon-themes-dir}")

normal_conf=$(find $themes_dir -maxdepth 1 -type f | grep "\/normal\.conf$")
source $normal_conf

for file in $(\find $themes_dir -maxdepth 1 -type f | grep "\.conf$"); do
	target_session_name=${file##*/}
	target_session_name=${target_session_name%.*}
	if [ $target_session_name = $session_name ]; then
		source $file
	fi
done

icon_format=""

if [ ${#auto_icons[@]} -gt 0 ]; then
	for ((I = 0, J = $base_index; I < $max_tabs; I++, J++)); do
		K=$((I % ${#auto_icons[@]}))
		is_target_format="?#{==:#I,$J}"
		icon_format="#{$is_target_format,${auto_icons[$K]} ,$icon_format}"
	done
fi

if [ ${#manual_icons[@]} -gt 0 ]; then
	for ((I = 0; I < ${#manual_icons[@]}; I++)); do
		icon_format="#{${manual_icons[$I]} ,$icon_format}"
	done
fi

window_status_format=""
window_status_current_format=""

for ((I = 0, J = $base_index; I < $max_tabs; I++, J++)); do
	K=$((I % ${#auto_colors[@]}))
	color_format=${auto_colors[$K]}

	if [ ${#manual_colors[@]} -gt 0 ]; then
		for ((L = 0; L < ${#manual_colors[@]}; L++)); do
			color_format="#{${manual_colors[$L]} ,$color_format}"
		done
	fi

	is_target_format="?#{==:#I,$J}"
	is_first_format="?#{!=:#I,${window_ids[0]}}"
	is_last_format="?#{!=:#I,${window_ids[$(($window_count - 1))]}}"

	tab_style=${style_tab//\#C/$color_format}
	tab_before_format="#{$is_first_format,$tab_before,$tab_before_first}"
	tab_before_format=${tab_before_format//\#C/$color_format}
	tab_after_format="#{$is_last_format,$tab_after,$tab_after_last}"
	tab_after_format=${tab_after_format//\#C/$color_format}

	window_status_format+="#{$is_target_format,$tab_style$tab_before_format$tab_style,}"
	icon_style=${style_tab_icon//\#C/$color_format}
	window_status_format+="#{$is_target_format,$icon_style$icon_format,}"
	title_style=${style_tab_title//\#C/$color_format}
	window_status_format+="#{$is_target_format,$title_style$tab_title$tab_after_format,}"

	tab_style=${style_tab_active//\#C/$color_format}
	tab_active_before_format="#{$is_first_format,$tab_active_before,$tab_active_before_first}"
	tab_active_before_format=${tab_active_before_format//\#C/$color_format}
	tab_active_after_format="#{$is_last_format,$tab_active_after,$tab_active_after_last}"
	tab_active_after_format=${tab_active_after_format//\#C/$color_format}

	window_status_current_format+="#{$is_target_format,$tab_style$tab_active_before_format$tab_style,}"
	icon_style=${style_tab_active_icon//\#C/$color_format}
	window_status_current_format+="#{$is_target_format,$icon_style$icon_format,}"
	title_style=${style_tab_active_title//\#C/$color_format}
	window_status_current_format+="#{$is_target_format,$title_style$tab_active_title$tab_active_after_format,}"
done

tmux set-window-option -g window-status-format ""
tmux set-window-option -g window-status-current-format ""

for ((I = $base_index; I < $(($window_count + $base_index)); I++)); do
	tmux set-window-option -t $I window-status-format "$window_status_format"
	tmux set-window-option -t $I window-status-current-format "$window_status_current_format"
	tmux set-window-option -t $I window-status-separator "$tab_separator"
done
