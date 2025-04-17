# tmux-tabicon

tmuxのウィンドウタブ（window-status）を色、アイコン、高度なフォーマットでカスタマイズするための強力なプラグインです。

[English](README.md)

## スクリーンショット

自動色とアイコンを使用したデフォルトテーマ：
[![デフォルトテーマ](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)

プロセス固有のアイコンを使用したカスタムテーマ：
[![カスタムテーマ](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)

## tmux-tabiconとは？

tmux-tabiconは、tmuxのウィンドウタブ（window-status）の高度なカスタマイズを可能にするプラグインです。以下のことができます：

- タブに自動または条件付きの色を適用する
- タブにアイコンを追加する
- アクティブなタブと非アクティブなタブの外観をカスタマイズする
- 最初と最後のタブに特別なフォーマットを適用する
- セッション固有のテーマを作成する

## インストール

### 前提条件

- [tmux](https://github.com/tmux/tmux) (バージョン2.9以降を推奨)
- [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)

### TPMを使用する方法（推奨）

`~/.tmux.conf`に以下を追加します：

```bash
# テーマディレクトリを設定（このディレクトリが存在しない場合は作成してください）
set -g @tmux-tabicon-themes-dir "~/.config/tmux/tabicon-themes"

# プラグインを追加
set -g @plugin 'mocaffy/tmux-tabicon'

# TMUXプラグインマネージャを初期化（tmux.confの最後に記述してください）
run '~/.tmux/plugins/tpm/tpm'
```

その後、`prefix` + <kbd>I</kbd>を押してプラグインをインストールします。

### 手動インストール

リポジトリをクローンします：

```bash
git clone https://github.com/mocaffy/tmux-tabicon.git ~/.tmux/plugins/tmux-tabicon
```

`~/.tmux.conf`に以下を追加します：

```bash
# テーマディレクトリを設定（このディレクトリが存在しない場合は作成してください）
set -g @tmux-tabicon-themes-dir "~/.config/tmux/tabicon-themes"

# プラグインを読み込む
run-shell ~/.tmux/plugins/tmux-tabicon/tabicon.tmux
```

## 動作の仕組み

tmux-tabiconは以下のように動作します：

1. 色、アイコン、フォーマットを定義する設定ファイルを読み込む
2. これらの設定に基づいてtmuxフォーマット文字列を生成する
3. これらのフォーマット文字列をwindow-status-formatとwindow-status-current-formatに適用する
4. tmuxイベント（新しいウィンドウ、ペインの終了など）が発生したときに表示を更新する

このプラグインはtmuxフックを使用して、tmuxセッションで変更が発生したときにタブの外観を自動的に更新します。

## 設定

### テーマディレクトリ

テーマディレクトリを作成し、tmux.confで設定します：

```bash
set -g @tmux-tabicon-themes-dir "~/.config/tmux/tabicon-themes"
```

### 設定ファイル

tmux-tabiconは以下の設定ファイルを使用します：

1. **default.conf** - 組み込みのデフォルト設定（変更しないでください）
2. **normal.conf** - すべてのセッションに適用されるカスタム設定（テーマディレクトリに作成します）
3. **[セッション名].conf** - セッション固有の設定（オプション、テーマディレクトリに作成します）

### テーマの作成

テーマディレクトリに`normal.conf`ファイルを作成します：

```bash
mkdir -p ~/.config/tmux/tabicon-themes
touch ~/.config/tmux/tabicon-themes/normal.conf
```

### 設定オプション

テーマファイルで設定できる主なオプションは以下の通りです：

#### 色

```bash
# 自動色（タブを通じてローテーションされる）
auto_colors=("#9a348e" "#da627d" "#fca17d" "#86bbd8" "#06969A" "#33658a")

# 条件付き色（ウィンドウ名やその他の条件に基づいて適用される）
manual_colors=("?#{==:#W,[tmux]},#0000ff")
```

#### アイコン

```bash
# 自動アイコン（タブを通じてローテーションされる）
auto_icons=("●")

# 条件付きアイコン（ウィンドウ名やその他の条件に基づいて適用される）
manual_icons=("?#{==:#W,[tmux]},")
```

#### 通常タブのスタイル

```bash
# ウィンドウタイトルのフォーマット
tab_title="#W"

# タブの先頭部分のフォーマット
tab_before_first=" "      # 最初のタブ用
tab_before="#[fg=#222233]▏"  # その他のタブ用

# スタイル設定
style_tab=""              # 基本スタイル
style_tab_icon="#[fg=#C]"  # アイコンスタイル（#Cは色に置き換えられる）
style_tab_title="#[fg=#ffffff]"  # タイトルスタイル

# タブの末尾部分のフォーマット
tab_after=" "            # ほとんどのタブ用
tab_after_last=" "       # 最後のタブ用
```

#### アクティブタブのスタイル

```bash
# アクティブウィンドウタイトルのフォーマット
tab_active_title="#W"

# アクティブタブの先頭部分のフォーマット
tab_active_before_first=" "
tab_active_before="#[fg=#222233]▏"

# アクティブタブのスタイル設定
style_tab_active="#[bg=#C]#[fg=#ffffff]"  # 基本スタイル
style_tab_active_icon=""  # アイコンスタイル
style_tab_active_title="" # タイトルスタイル

# アクティブタブの末尾部分のフォーマット
tab_active_after=" "
tab_active_after_last=" "
```

#### セパレータ

```bash
# タブ間の文字
tab_separator=""
```

## 設定例

### 自動色を使用した基本テーマ

```bash
# タブをローテーションする色
auto_colors=("#9a348e" "#da627d" "#fca17d" "#86bbd8")

# すべてのタブにドットをアイコンとして使用
auto_icons=("●")

# シンプルなタブフォーマット
tab_before=" "
tab_after=" "
style_tab_icon="#[fg=#C]"  # #Cは現在の色に置き換えられます
style_tab_title="#[fg=#ffffff]"
```

### プロセス固有のテーマ

```bash
# 特定のプロセス用の色
manual_colors=(
  "?#{==:#{pane_current_command},vim},#98c379"
  "?#{==:#{pane_current_command},ssh},#e06c75"
  "?#{==:#{pane_current_command},node},#61afef"
)

# 特定のプロセス用のアイコン
manual_icons=(
  "?#{==:#{pane_current_command},vim},"
  "?#{==:#{pane_current_command},ssh},"
  "?#{==:#{pane_current_command},node},"
)

# モダンなタブスタイル
tab_before="#[fg=#303030]│"
tab_after=" "
style_tab_icon="#[fg=#C]"
style_tab_title="#[fg=#ffffff]"
```

## 高度な使用法

### 条件付きフォーマット

tmuxの条件付きフォーマットを使用して、ウィンドウのプロパティに基づいて色やアイコンを変更できます：

```bash
# 条件に基づく色
manual_colors=(
  "?#{==:#{pane_current_command},ssh},#ff0000"  # SSHセッションを赤色に
  "?#{==:#{window_name},logs},#00ff00"          # "logs"という名前のウィンドウを緑色に
  "?#{==:#{pane_current_path},~/work},#0000ff"  # ~/workディレクトリのウィンドウを青色に
)

# 条件に基づくアイコン
manual_icons=(
  "?#{==:#{pane_current_command},vim},"      # Vimアイコン
  "?#{==:#{pane_current_command},docker},"   # Dockerアイコン
  "?#{==:#{window_name},server},"           # サーバーアイコン
)
```

### セッション固有のテーマ

セッション名に基づいた設定ファイルを作成します：

```bash
# "dev"という名前のセッション用
touch ~/.config/tmux/tabicon-themes/dev.conf
```

この設定は、「dev」セッションにいる場合にのみ適用されます。

## テーマ開発ガイド

1. **コピーから始める**
   ```bash
   cp ~/.tmux/plugins/tmux-tabicon/default.conf ~/.config/tmux/tabicon-themes/normal.conf
   ```

2. **変数を理解する**
   - `auto_*`: タブをローテーションする値
   - `manual_*`: ウィンドウのプロパティに基づく条件付きの値
   - `style_*`: タブの各部分のスタイル文字列
   - `tab_*`: タブの構造要素

3. **変更をテストする**
   - 小さな変更を加えて`prefix` + <kbd>r</kbd>で更新
   - `tmux display-message`を使用して変数をデバッグ
   - tmuxサーバーログでエラーを確認

4. **テーマを共有する**
   - [tmux-tabicon-theme](https://github.com/mocaffy/tmux-tabicon-theme)への貢献を検討

## トラブルシューティング

### よくある問題

1. **タブが更新されない**
   - `prefix` + <kbd>r</kbd>で手動更新
   - テーマディレクトリの設定を確認
   - 設定ファイルのパーミッションを確認
   - テーマファイルの構文エラーを確認

2. **アイコンが表示されない**
   - 使用しているアイコンがターミナルでサポートされているか確認
   - 互換性のあるフォント（例：Nerd Fonts）を使用しているか確認
   - まずは単純なUnicode文字を試す

3. **色が機能しない**
   - ターミナルが256色またはTrue Colorをサポートしているか確認
   - tmuxの色設定を確認（`set -g default-terminal`）
   - 16進数の色の代わりに標準的な色コードを試す

4. **パフォーマンスの問題**
   - 条件チェックの数を減らす
   - 複雑なフォーマット文字列を簡素化
   - tmuxサーバーログで警告を確認

### デバッグモード

デバッグモードを有効にしてより詳細な情報を表示：
```bash
set -g @tmux-tabicon-debug "true"
```

## 貢献

貢献を歓迎します！プルリクエストを提出する前に[貢献ガイドライン](CONTRIBUTING.md)をお読みください。

1. リポジトリをフォーク
2. 機能ブランチを作成
3. 変更を加える
4. プルリクエストを提出

## 関連プロジェクト

- [tmux-tabicon-theme](https://github.com/mocaffy/tmux-tabicon-theme) - tmux-tabicon用の既製テーマ
- [tmux-powerline](https://github.com/erikw/tmux-powerline) - 同様のステータスラインカスタマイズ
- [tmux-themepack](https://github.com/jimeh/tmux-themepack) - tmuxテーマコレクション

## 変更履歴

変更の一覧については[CHANGELOG.md](CHANGELOG.md)を参照してください。

## ライセンス

[MIT](LICENSE)