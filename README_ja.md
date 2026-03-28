# tmux-tabicon

tmuxのウィンドウタブ（window-status）を色、アイコン、高度なフォーマットでカスタマイズするプラグインです。

[![スクリーンショット](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)
[![スクリーンショット](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d21d.png)

## インストール

### 前提条件

- [tmux](https://github.com/tmux/tmux)（バージョン2.9以降を推奨）
- [TPM](https://github.com/tmux-plugins/tpm)（Tmux Plugin Manager）

### TPMを使う方法（推奨）

`~/.tmux.conf` に以下を追加します：

```bash
set -g @plugin 'mocaffy/tmux-tabicon'

# TMUXプラグインマネージャの初期化（tmux.confの末尾に記述）
run '~/.tmux/plugins/tpm/tpm'
```

その後、`prefix` + <kbd>I</kbd> を押してプラグインをインストールします。

### 手動インストール

```bash
git clone https://github.com/mocaffy/tmux-tabicon.git ~/.tmux/plugins/tmux-tabicon
```

`~/.tmux.conf` に以下を追加します：

```bash
run-shell ~/.tmux/plugins/tmux-tabicon/tabicon.tmux
```

## 設定

設定は以下の順で読み込まれます。後のレイヤーが前のレイヤーを上書きします。

```
Layer 0: 組み込みデフォルト値
Layer 1: @tmux-tabicon-preset で選択したプリセット
Layer 2: tmux.conf の個別 @tmux-tabicon-* オプション
```

### プリセット選択

```bash
set -g @tmux-tabicon-preset "island-dark"
```

利用可能なプリセット：

| 名前 | 説明 |
|---|---|
| `island-dark` | ソリッドな背景のダークテーマ |
| `capsule-light` | カプセル型セパレータのライトテーマ |

プリセットを無効にする場合：

```bash
set -g @tmux-tabicon-preset "none"
```

### スカラー値の上書き

プリセットの任意の値を個別に上書きできます：

```bash
set -g @tmux-tabicon-tab-title           "#I:#W"   # タイトルの書式
set -g @tmux-tabicon-tab-active-title    "#I:#W"
set -g @tmux-tabicon-tab-separator       " "

set -g @tmux-tabicon-style-tab           "#[bg=#1e1e2e]"
set -g @tmux-tabicon-style-tab-icon      "#[fg=#C]"   # #C はタブの色に置換される
set -g @tmux-tabicon-style-tab-title     "#[fg=#cdd6f4]"

set -g @tmux-tabicon-style-tab-active    "#[bg=#C]#[fg=#1e1e2e]"
set -g @tmux-tabicon-style-tab-active-icon   ""
set -g @tmux-tabicon-style-tab-active-title  ""

set -g @tmux-tabicon-tab-before          "#[fg=#45475a]▏"
set -g @tmux-tabicon-tab-before-first    " "
set -g @tmux-tabicon-tab-after           " "
set -g @tmux-tabicon-tab-after-last      " "

set -g @tmux-tabicon-tab-active-before         "#[fg=#45475a]▏"
set -g @tmux-tabicon-tab-active-before-first   " "
set -g @tmux-tabicon-tab-active-after          " "
set -g @tmux-tabicon-tab-active-after-last     " "
```

### 配列値の上書き

配列は `|` 区切りの文字列で指定します：

```bash
# タブに順番に割り当てる色（サイクル）
set -g @tmux-tabicon-auto-colors "#f38ba8|#fab387|#f9e2af|#a6e3a1|#89b4fa|#cba6f7"

# タブに順番に割り当てるアイコン（サイクル）
set -g @tmux-tabicon-auto-icons "●"

# ウィンドウ名に応じたアイコン（tmux 条件フォーマット）
set -g @tmux-tabicon-manual-icons \
  "?#{==:#W,nvim},|?#{==:#W,node},󰎙|?#{==:#W,python},"

# ウィンドウ名に応じた色
set -g @tmux-tabicon-manual-colors \
  "?#{==:#{pane_current_command},ssh},#ff0000"
```

`manual-icons` / `manual-colors` が優先して評価され、どの条件にもマッチしない場合は `auto-icons` / `auto-colors` にフォールバックします。

### `#C` プレースホルダー

スタイル文字列内の `#C` は、そのタブに解決された色（`auto-colors` または `manual-colors` の値）に置換されます。アイコンと背景の両方に同じ色を使う場合に便利です。

## 設定例

### 最小構成（プリセットのみ）

```bash
set -g @tmux-tabicon-preset "island-dark"
set -g @plugin 'mocaffy/tmux-tabicon'
run '~/.tmux/plugins/tpm/tpm'
```

### プリセット＋上書き

```bash
set -g @tmux-tabicon-preset "capsule-light"
set -g @tmux-tabicon-tab-title "#I:#W"
set -g @tmux-tabicon-auto-colors "#f38ba8|#fab387|#f9e2af|#a6e3a1|#89b4fa|#cba6f7"
set -g @tmux-tabicon-manual-icons \
  "?#{==:#W,nvim},|?#{==:#W,node},󰎙"
set -g @plugin 'mocaffy/tmux-tabicon'
run '~/.tmux/plugins/tpm/tpm'
```

## トラブルシューティング

タブが更新されない場合：

1. `prefix` + <kbd>r</kbd> で手動更新する
2. `@tmux-tabicon-preset` に指定した名前が有効なプリセット名か確認する

## ライセンス

[MIT](LICENSE)
