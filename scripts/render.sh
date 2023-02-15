#!/usr/bin/env bash

#######################################
# tmux から得る情報
# base_index	: ウィンドウ ID のベースインデックス
# window_count	: ウィンドウの数
# window_ids	: ウィンドウ ID リスト
# session_name	: セッション名
# themes_dir	: テーマのディレクトリ
#######################################
base_index=$(tmux display -p "#{E:base-index}")
window_count=$(tmux list-windows | wc -l)
window_ids=($(tmux lsw | sed -e 's/:.*//g'))
session_name=$(tmux display -p "#S")
themes_dir=$(tmux display -p "#{@tmux-tabicon-themes-dir}")

#######################################
# デフォルト設定の読み込み
#######################################
cd $(dirname $0) && cd ..
source ./default.conf

#######################################
# ユーザー設定の読み込み
#######################################
cd $themes_dir
normal_conf=$(find $themes_dir -maxdepth 1 -type f | grep "\/normal\.conf$")
source $normal_conf

for file in $(\find $themes_dir -maxdepth 1 -type f | grep "\.conf$"); do
	target_session_name=${file##*/}
	target_session_name=${target_session_name%.*}
	if [ $target_session_name = $session_name ]; then
		source $file
	fi
done

#######################################
# アイコンのフォーマットを作成
#######################################
icon_format=""

if [ ${#auto_icons[@]} -gt 0 ]; then
	for ((I = 0; I < ${#auto_icons[@]}; I++)); do
		is_target_format="?#{==:$I,#(echo \$((#I - (#I / ${#auto_icons[@]}) * ${#auto_icons[@]})))}"
		icon_format="#{$is_target_format,${auto_icons[$I]} ,$icon_format}"
	done
fi

if [ ${#manual_icons[@]} -gt 0 ]; then
	for ((I = 0; I < ${#manual_icons[@]}; I++)); do
		icon_format="#{${manual_icons[$I]} ,$icon_format}"
	done
fi

#######################################
# 色のフォーマットを作成
#######################################
color_format=""

if [ ${#auto_colors[@]} -gt 0 ]; then
	for ((I = 0; I < ${#auto_colors[@]}; I++)); do
		is_target_format="?#{==:$I,#(echo \$((#I - (#I / ${#auto_colors[@]}) * ${#auto_colors[@]})))}"
		color_format="#{$is_target_format,${auto_colors[$I]} ,$color_format}"
	done
fi

if [ ${#manual_colors[@]} -gt 0 ]; then
	for ((I = 0; I < ${#manual_colors[@]}; I++)); do
		color_format="#{${manual_colors[$I]} ,$color_format}"
	done
fi

#######################################
# 条件フォーマットを作成
#######################################
is_first_format="?#{!=:#I,${window_ids[0]}}"
is_last_format="?#{!=:#I,${window_ids[$(($window_count - 1))]}}"

#######################################
# 通常タブのフォーマットを作成
#######################################
tab_style=${style_tab//\#C/$color_format}
tab_before_format="#{$is_first_format,$tab_before,$tab_before_first}"
tab_before_format=${tab_before_format//\#C/$color_format}
tab_after_format="#{$is_last_format,$tab_after,$tab_after_last}"
tab_after_format=${tab_after_format//\#C/$color_format}

icon_style=${style_tab_icon//\#C/$color_format}
title_style=${style_tab_title//\#C/$color_format}
window_status_format+="$tab_style$tab_before_format$tab_style"
window_status_format+="$icon_style$icon_format"
window_status_format+="$title_style$tab_title$tab_after_format"

#######################################
# アクティブなタブのフォーマットを作成
#######################################
tab_style=${style_tab_active//\#C/$color_format}
tab_active_before_format="#{$is_first_format,$tab_active_before,$tab_active_before_first}"
tab_active_before_format=${tab_active_before_format//\#C/$color_format}
tab_active_after_format="#{$is_last_format,$tab_active_after,$tab_active_after_last}"
tab_active_after_format=${tab_active_after_format//\#C/$color_format}

icon_style=${style_tab_active_icon//\#C/$color_format}
title_style=${style_tab_active_title//\#C/$color_format}
window_status_current_format+="$tab_style$tab_active_before_format$tab_style"
window_status_current_format+="$icon_style$icon_format"
window_status_current_format+="$title_style$tab_active_title$tab_active_after_format"

#######################################
# グローバルな設定を削除
#######################################
tmux set-window-option -g window-status-format ""
tmux set-window-option -g window-status-current-format ""

#######################################
# 現在のセッションにフォーマットを設定
#######################################
for id in ${window_ids[@]}; do
	tmux set-window-option -t $id window-status-format "$window_status_format"
	tmux set-window-option -t $id window-status-current-format "$window_status_current_format"
	tmux set-window-option -t $id window-status-separator "$tab_separator"
done
