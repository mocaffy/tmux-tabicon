# tmux-tabicon

A powerful plugin for customizing tmux window tabs (window-status) with colors, icons, and advanced formatting.

[![screenshot](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)
[![screenshot](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)

## What is tmux-tabicon?

tmux-tabicon is a plugin that enables advanced customization of tmux window tabs (window-status). It allows you to:

- Apply automatic or conditional colors to tabs
- Add icons to tabs
- Customize the appearance of active and inactive tabs
- Apply special formatting to first and last tabs
- Create session-specific themes

## Installation

### Prerequisites

- [tmux](https://github.com/tmux/tmux) (version 2.9 or later recommended)
- [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)

### Using TPM (recommended)

Add the following to your `~/.tmux.conf`:

```bash
# Set the themes directory (create this directory if it doesn't exist)
set -g @tmux-tabicon-themes-dir "~/.config/tmux/tabicon-themes"

# Add the plugin
set -g @plugin 'mocaffy/tmux-tabicon'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

Then press `prefix` + <kbd>I</kbd> to install the plugin.

### Manual Installation

Clone the repository:

```bash
git clone https://github.com/mocaffy/tmux-tabicon.git ~/.tmux/plugins/tmux-tabicon
```

Add the following to your `~/.tmux.conf`:

```bash
# Set the themes directory (create this directory if it doesn't exist)
set -g @tmux-tabicon-themes-dir "~/.config/tmux/tabicon-themes"

# Source the plugin
run-shell ~/.tmux/plugins/tmux-tabicon/tabicon.tmux
```

## How It Works

tmux-tabicon works by:

1. Loading configuration files that define colors, icons, and formatting
2. Generating tmux format strings based on these configurations
3. Applying these format strings to window-status-format and window-status-current-format
4. Refreshing the display when tmux events occur (new window, pane exit, etc.)

The plugin uses tmux hooks to automatically update the tab appearance when changes occur in your tmux session.

## Configuration

### Theme Directory

Create a themes directory and set it in your tmux.conf:

```bash
set -g @tmux-tabicon-themes-dir "~/.config/tmux/tabicon-themes"
```

### Configuration Files

tmux-tabicon supports both YAML and Bash configuration formats:

1. **default.yml/default.conf** - Built-in default settings (don't modify these)
2. **normal.yml/normal.conf** - Your custom settings that apply to all sessions (create in your themes directory)
3. **[session-name].yml/[session-name].conf** - Session-specific settings (optional, create in your themes directory)

YAML format is recommended for new users as it's more readable and less error-prone.

### Creating Your Theme

#### Using YAML (Recommended)

Create a `normal.yml` file in your themes directory:

```bash
mkdir -p ~/.config/tmux/tabicon-themes
touch ~/.config/tmux/tabicon-themes/normal.yml
```

Example YAML configuration:

```yaml
# Color settings
colors:
  auto:
    - "#9a348e"  # Purple
    - "#da627d"  # Pink
    - "#fca17d"  # Orange
  manual:
    - condition: "#{==:#W,[tmux]}"
      color: "#0000ff"

# Icon settings
icons:
  auto:
    - "●"
  manual:
    - condition: "#{==:#W,[tmux]}"
      icon: ""

# Normal tab appearance
normal_tab:
  title: "#W"
  formatting:
    before_first: " "
    before: "#[fg=#222233]▏"
    after: " "
    after_last: " "
  style:
    base: ""
    icon: "#[fg=#C]"
    title: "#[fg=#ffffff]"

# Active tab appearance
active_tab:
  title: "#W"
  formatting:
    before_first: " "
    before: "#[fg=#222233]▏"
    after: " "
    after_last: " "
  style:
    base: "#[bg=#C]#[fg=#ffffff]"
    icon: ""
    title: ""

# Character between tabs
separator: ""
```

#### Using Bash (Legacy)

Create a `normal.conf` file in your themes directory:

```bash
mkdir -p ~/.config/tmux/tabicon-themes
touch ~/.config/tmux/tabicon-themes/normal.conf
```

### Configuration Options

Here are the key configuration options you can set in your theme files:

#### Colors

YAML format:
```yaml
colors:
  # Automatic colors (rotated through tabs)
  auto:
    - "#9a348e"
    - "#da627d"
    - "#fca17d"
  
  # Conditional colors (applied based on window name or other conditions)
  manual:
    - condition: "#{==:#W,[tmux]}"
      color: "#0000ff"
```

Bash format:
```bash
# Automatic colors (rotated through tabs)
auto_colors=("#9a348e" "#da627d" "#fca17d" "#86bbd8" "#06969A" "#33658a")

# Conditional colors (applied based on window name or other conditions)
manual_colors=("?#{==:#W,[tmux]},#0000ff")
```

#### Icons

YAML format:
```yaml
icons:
  # Automatic icons (rotated through tabs)
  auto:
    - "●"
  
  # Conditional icons (applied based on window name or other conditions)
  manual:
    - condition: "#{==:#W,[tmux]}"
      icon: ""
```

Bash format:
```bash
# Automatic icons (rotated through tabs)
auto_icons=("●")

# Conditional icons (applied based on window name or other conditions)
manual_icons=("?#{==:#W,[tmux]},")
```

#### Normal Tab Styling

YAML format:
```yaml
normal_tab:
  # Window title format
  title: "#W"
  
  # Formatting for tab beginning and end
  formatting:
    before_first: " "      # For the first tab
    before: "#[fg=#222233]▏"  # For other tabs
    after: " "            # For most tabs
    after_last: " "       # For the last tab
  
  # Style settings
  style:
    base: ""              # Base style
    icon: "#[fg=#C]"      # Icon style (#C is replaced with color)
    title: "#[fg=#ffffff]"  # Title style
```

Bash format:
```bash
# Window title format
tab_title="#W"

# Formatting for tab beginning
tab_before_first=" "      # For the first tab
tab_before="#[fg=#222233]▏"  # For other tabs

# Style settings
style_tab=""              # Base style
style_tab_icon="#[fg=#C]"  # Icon style (#C is replaced with color)
style_tab_title="#[fg=#ffffff]"  # Title style

# Formatting for tab end
tab_after=" "            # For most tabs
tab_after_last=" "       # For the last tab
```

#### Active Tab Styling

YAML format:
```yaml
active_tab:
  # Active window title format
  title: "#W"
  
  # Formatting for active tab beginning and end
  formatting:
    before_first: " "
    before: "#[fg=#222233]▏"
    after: " "
    after_last: " "
  
  # Style settings for active tab
  style:
    base: "#[bg=#C]#[fg=#ffffff]"  # Base style
    icon: ""                      # Icon style
    title: ""                     # Title style
```

Bash format:
```bash
# Active window title format
tab_active_title="#W"

# Formatting for active tab beginning
tab_active_before_first=" "
tab_active_before="#[fg=#222233]▏"

# Style settings for active tab
style_tab_active="#[bg=#C]#[fg=#ffffff]"  # Base style
style_tab_active_icon=""  # Icon style
style_tab_active_title="" # Title style

# Formatting for active tab end
tab_active_after=" "
tab_active_after_last=" "
```

#### Separator

YAML format:
```yaml
# Character between tabs
separator: ""
```

Bash format:
```bash
# Character between tabs
tab_separator=""
```

## Advanced Usage

### Conditional Formatting

You can use tmux's conditional formatting to change colors or icons based on window properties:

```bash
# Make SSH windows red
manual_colors=("?#{==:#{pane_current_command},ssh},#ff0000")

# Add special icon for vim windows
manual_icons=("?#{==:#{pane_current_command},vim},")
```

### Session-Specific Themes

Create a configuration file named after your session:

```bash
# For a session named "dev"
touch ~/.config/tmux/tabicon-themes/dev.conf
```

This configuration will only apply when you're in the "dev" session.

## Troubleshooting

If your tabs aren't updating properly:

1. Press `prefix` + <kbd>r</kbd> to manually refresh the tabs
2. Check that your themes directory is set correctly
3. Verify your configuration files have the correct syntax

## Related Projects

- [tmux-tabicon-theme](https://github.com/mocaffy/tmux-tabicon-theme) - Pre-made themes for tmux-tabicon

## License

[MIT](LICENSE)
