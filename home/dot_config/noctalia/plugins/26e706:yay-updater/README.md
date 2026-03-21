# Yay Updater Plugin

A Noctalia plugin that checks for Arch Linux updates using yay and displays them on the bar.

## Features

- **Automatic Update Checks**: Checks for updates every 4 hours (configurable from 1-24 hours)
- **Visual Indicator**: Shows the number of available updates on the bar
- **Package List**: Click the widget to view detailed list of packages that can be updated
- **One-Click Updates**: Update your system directly from the panel with a single button click
- **Customizable**: Configure check interval, terminal emulator, icon, and visibility options
- **Auto-refresh**: Optionally refresh update list when opening the panel

## Requirements

- **yay**: The AUR helper must be installed on your system
- **pacman-contrib**: Provides `checkupdates` command for syncing official repos (usually pre-installed)
- **Terminal emulator**: A terminal emulator like `foot`, `kitty`, `alacritty`, or `konsole`

## Installation

1. Clone or download this plugin to your Noctalia plugins directory
2. Enable the plugin in Noctalia settings
3. Add the bar widget to your bar configuration

## Configuration

Open the plugin settings to customize:

### General Settings
- **Hide widget when no updates**: Only show the widget when updates are available
- **Auto-refresh on panel open**: Automatically check for updates when opening the panel

### Appearance
- **Widget Icon**: Choose a custom icon for the bar widget (default: `software-update-available`)

### Update Check Interval
- Configure how often to check for updates (1-24 hours, default: 4 hours)

### Terminal Settings
- **Terminal Command**: Specify your preferred terminal emulator
  - Examples: `foot -e`, `kitty -e`, `alacritty -e`, `konsole -e`
  - Use `{}` as a placeholder if you need to customize the command structure

## Usage

### Bar Widget
- Shows the number of available updates
- Displays a spinning loader icon while checking
- **Left click:** Open the panel with package details
- **Right click:** Open context menu with options:
  - **Check Now:** Manually trigger an update check
  - **Update System:** Run system update (only available when updates exist)
  - **Settings:** Open plugin settings to customize icon, interval, and terminal

### Panel
- View the complete list of packages sorted alphabetically
- Shows current and new version for each package
- Click "Update Now" to run `yay -Syu` in your configured terminal
- Click "Refresh" to manually check for updates

### Manual Actions
From the settings page, you can:
- **Check Now**: Immediately check for updates
- **Update System**: Run the update command (only enabled when updates are available)

## IPC Commands

You can control the plugin via command line:

```bash
# Check for updates
qs -c noctalia-shell ipc call plugin:yay-updater check

# Run system update
qs -c noctalia-shell ipc call plugin:yay-updater update
```

## Technical Details

- Runs `checkupdates` to sync and check official repository updates (no sudo required)
- Runs `yay -Qua` to check AUR package updates
- Sorts packages alphabetically for easy browsing
- Parses package names and version information
- Opens your configured terminal with `yay -Syu` for system updates
- Automatically refreshes the package list after updates complete

**Note:** The plugin uses `checkupdates` which syncs to a temporary database copy, so you get accurate results without requiring sudo or system-wide database sync.

## License

MIT

## Author

Custom
