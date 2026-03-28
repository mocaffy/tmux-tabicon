# tmux-tabicon

A plugin for customizing tmux window tabs with colors, icons, and advanced formatting.

[![screenshot](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)
[![screenshot](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d21d.png)

## Installation

### Prerequisites

- [tmux](https://github.com/tmux/tmux) (version 2.9 or later recommended)
- [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)

### Using TPM (recommended)

Add the following to your `~/.tmux.conf`:

```bash
set -g @plugin 'mocaffy/tmux-tabicon'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

Then press `prefix` + <kbd>I</kbd> to install the plugin.

### Manual Installation

```bash
git clone https://github.com/mocaffy/tmux-tabicon.git ~/.tmux/plugins/tmux-tabicon
```

Add to your `~/.tmux.conf`:

```bash
run-shell ~/.tmux/plugins/tmux-tabicon/tabicon.tmux
```

## Configuration

Settings are loaded in the following order. Later layers override earlier ones.

```
Layer 0: built-in defaults
Layer 1: preset selected via @tmux-tabicon-preset
Layer 2: individual @tmux-tabicon-* options in tmux.conf
```

### Preset selection

```bash
set -g @tmux-tabicon-preset "island-dark"
```

Available presets:

| Name | Description |
|---|---|
| `island-dark` | Dark theme with solid background tabs |
| `capsule-light` | Light theme with capsule-style separators |

To disable preset loading entirely:

```bash
set -g @tmux-tabicon-preset "none"
```

### Scalar overrides

Any preset value can be overridden individually:

```bash
set -g @tmux-tabicon-tab-title           "#I:#W"   # window title format
set -g @tmux-tabicon-tab-active-title    "#I:#W"
set -g @tmux-tabicon-tab-separator       " "

set -g @tmux-tabicon-style-tab           "#[bg=#1e1e2e]"
set -g @tmux-tabicon-style-tab-icon      "#[fg=#C]"   # #C is replaced with the tab color
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

### Array overrides

Arrays use `|` as a delimiter:

```bash
# Colors assigned to tabs in sequence (cycling)
set -g @tmux-tabicon-auto-colors "#f38ba8|#fab387|#f9e2af|#a6e3a1|#89b4fa|#cba6f7"

# Icons assigned to tabs in sequence (cycling)
set -g @tmux-tabicon-auto-icons "●"

# Per-window icon based on window name (tmux conditional format)
set -g @tmux-tabicon-manual-icons \
  "?#{==:#W,nvim},|?#{==:#W,node},󰎙|?#{==:#W,python},"

# Per-window color based on window name
set -g @tmux-tabicon-manual-colors \
  "?#{==:#{pane_current_command},ssh},#ff0000"
```

`manual-icons` and `manual-colors` are checked first; if no condition matches, `auto-icons` and `auto-colors` are used as fallback.

### The `#C` placeholder

In style strings, `#C` is replaced with the resolved color for that tab (from `auto-colors` or `manual-colors`). This lets you use the tab color in both icon and background styles without duplication.

## Examples

### Minimal (preset only)

```bash
set -g @tmux-tabicon-preset "island-dark"
set -g @plugin 'mocaffy/tmux-tabicon'
run '~/.tmux/plugins/tpm/tpm'
```

### Preset with overrides

```bash
set -g @tmux-tabicon-preset "capsule-light"
set -g @tmux-tabicon-tab-title "#I:#W"
set -g @tmux-tabicon-auto-colors "#f38ba8|#fab387|#f9e2af|#a6e3a1|#89b4fa|#cba6f7"
set -g @tmux-tabicon-manual-icons \
  "?#{==:#W,nvim},|?#{==:#W,node},󰎙"
set -g @plugin 'mocaffy/tmux-tabicon'
run '~/.tmux/plugins/tpm/tpm'
```

## Troubleshooting

If tabs are not updating:

1. Press `prefix` + <kbd>r</kbd> to manually refresh
2. Check that `@tmux-tabicon-preset` matches an available preset name

## License

[MIT](LICENSE)
