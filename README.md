# tmux-tabicon

A powerful plugin for customizing tmux window tabs (window-status) with colors, icons, and advanced formatting.

[日本語](README_ja.md)

## Screenshots

Default theme with automatic colors and icons:
[![Default theme](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)](https://user-images.githubusercontent.com/45122432/218329999-735b3a4f-23fc-4aea-95af-ca732cdfc03b.png)

Custom theme with process-specific icons:
[![Custom theme](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)](https://user-images.githubusercontent.com/45122432/218330413-3e45b472-dfaf-40bb-b7b4-38cd9e42d16d.png)

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

tmux-tabicon uses the following configuration files:

1. **default.conf** - Built-in default settings (don't modify this)
2. **normal.conf** - Your custom settings that apply to all sessions (create this in your themes directory)
3. **[session-name].conf** - Session-specific settings (optional, create in your themes directory)

### Creating Your Theme

Create a `normal.conf` file in your themes directory:

```bash
mkdir -p ~/.config/tmux/tabicon-themes
touch ~/.config/tmux/tabicon-themes/normal.conf
```

### Configuration Options

Here are the key configuration options you can set in your theme files:

#### Colors

```bash
# Automatic colors (rotated through tabs)
auto_colors=("#9a348e" "#da627d" "#fca17d" "#86bbd8" "#06969A" "#33658a")

# Conditional colors (applied based on window name or other conditions)
manual_colors=("?#{==:#W,[tmux]},#0000ff")
```

#### Icons

```bash
# Automatic icons (rotated through tabs)
auto_icons=("●")

# Conditional icons (applied based on window name or other conditions)
manual_icons=("?#{==:#W,[tmux]},")
```

#### Normal Tab Styling

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

```bash
# Character between tabs
tab_separator=""
```

## Example Configurations

### Basic Theme with Automatic Colors

```bash
# Rotate through these colors for tabs
auto_colors=("#9a348e" "#da627d" "#fca17d" "#86bbd8")

# Use a dot as the icon for all tabs
auto_icons=("●")

# Simple tab formatting
tab_before=" "
tab_after=" "
style_tab_icon="#[fg=#C]"  # #C is replaced with the current color
style_tab_title="#[fg=#ffffff]"
```

### Process-Specific Theme

```bash
# Colors for specific processes
manual_colors=(
  "?#{==:#{pane_current_command},vim},#98c379"
  "?#{==:#{pane_current_command},ssh},#e06c75"
  "?#{==:#{pane_current_command},node},#61afef"
)

# Icons for specific processes
manual_icons=(
  "?#{==:#{pane_current_command},vim},"
  "?#{==:#{pane_current_command},ssh},"
  "?#{==:#{pane_current_command},node},"
)

# Modern tab style
tab_before="#[fg=#303030]│"
tab_after=" "
style_tab_icon="#[fg=#C]"
style_tab_title="#[fg=#ffffff]"
```

## Advanced Usage

### Conditional Formatting

You can use tmux's conditional formatting to change colors or icons based on window properties:

```bash
# Colors based on conditions
manual_colors=(
  "?#{==:#{pane_current_command},ssh},#ff0000"  # SSH sessions in red
  "?#{==:#{window_name},logs},#00ff00"          # Windows named "logs" in green
  "?#{==:#{pane_current_path},~/work},#0000ff"  # Windows in ~/work in blue
)

# Icons based on conditions
manual_icons=(
  "?#{==:#{pane_current_command},vim},"      # Vim icon
  "?#{==:#{pane_current_command},docker},"   # Docker icon
  "?#{==:#{window_name},server},"           # Server icon
)
```

### Session-Specific Themes

Create a configuration file named after your session:

```bash
# For a session named "dev"
touch ~/.config/tmux/tabicon-themes/dev.conf
```

This configuration will only apply when you're in the "dev" session.

## Theme Development Guide

1. **Start with a Copy**
   ```bash
   cp ~/.tmux/plugins/tmux-tabicon/default.conf ~/.config/tmux/tabicon-themes/normal.conf
   ```

2. **Understand the Variables**
   - `auto_*`: Values rotated through tabs
   - `manual_*`: Conditional values based on window properties
   - `style_*`: Style strings for different parts of the tab
   - `tab_*`: Structural elements of the tab

3. **Test Your Changes**
   - Make small changes and refresh with `prefix` + <kbd>r</kbd>
   - Use `tmux display-message` to debug variables
   - Check the tmux server log for errors

4. **Share Your Theme**
   - Consider contributing to [tmux-tabicon-theme](https://github.com/mocaffy/tmux-tabicon-theme)

## Troubleshooting

### Common Issues

1. **Tabs Not Updating**
   - Press `prefix` + <kbd>r</kbd> to manually refresh
   - Check that your themes directory is set correctly
   - Verify configuration file permissions
   - Look for syntax errors in your theme files

2. **Icons Not Displaying**
   - Ensure your terminal supports the icons you're using
   - Check that you're using a compatible font (e.g., Nerd Fonts)
   - Try using simpler Unicode characters first

3. **Colors Not Working**
   - Verify your terminal supports 256 colors or true color
   - Check your tmux color settings (`set -g default-terminal`)
   - Try using standard color codes instead of hex colors

4. **Performance Issues**
   - Reduce the number of conditional checks
   - Simplify complex format strings
   - Check the tmux server log for warnings

### Debug Mode

Enable debug mode to see more information:
```bash
set -g @tmux-tabicon-debug "true"
```

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Related Projects

- [tmux-tabicon-theme](https://github.com/mocaffy/tmux-tabicon-theme) - Pre-made themes for tmux-tabicon
- [tmux-powerline](https://github.com/erikw/tmux-powerline) - Similar status line customization
- [tmux-themepack](https://github.com/jimeh/tmux-themepack) - Collection of tmux themes

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## License

[MIT](LICENSE)
