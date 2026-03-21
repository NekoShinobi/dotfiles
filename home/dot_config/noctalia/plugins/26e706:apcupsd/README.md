# APC UPS Monitor Plugin

Monitor your APC UPS (Uninterruptible Power Supply) status directly from your Noctalia bar. Get real-time information about battery level, load, runtime, and more.

## Features

- **Real-time UPS Monitoring**: Fetches status from apcupsd daemon every 5 seconds (configurable)
- **Visual Status Indicator**: Battery icon on the bar shows current status
- **Color-Coded Alerts**: Automatic color changes based on battery level and power status
  - Normal: Standard color when online
  - Warning: Yellow when battery is below 50% (configurable)
  - Critical: Red when battery is below 20% (configurable)
- **Detailed Panel View**: Click to see comprehensive UPS information including:
  - Battery charge level with visual progress bar
  - UPS status (Online, On Battery, Charging, etc.)
  - Load percentage with visual bar
  - Runtime remaining
  - Line voltage
  - Model and UPS name
  - All additional data from apcupsd
- **Customizable Display**: Choose to show battery percentage or load percentage on the bar
- **Context Menu**: Right-click for quick refresh

## Requirements

- **apcupsd**: APC UPS daemon must be installed and running
  ```bash
  # Arch Linux / Manjaro
  sudo pacman -S apcupsd
  
  # Debian / Ubuntu
  sudo apt install apcupsd
  
  # Fedora
  sudo dnf install apcupsd
  ```
- **APC UPS Device**: Connected via USB or network
- **Noctalia Shell**: Version 4.0.0 or higher

## Installation

1. Clone or download this plugin to your Noctalia plugins directory:
   ```bash
   cd ~/.config/noctalia/plugins
   git clone https://github.com/NekoShinobi/noctalia-plugins
   ```

2. Enable the plugin in Noctalia settings

3. Configure apcupsd if not already done:
   ```bash
   sudo systemctl enable --now apcupsd
   ```

## Configuration

Access settings by right-clicking the widget → Settings, or through the Noctalia plugin manager.

### General Settings
- **Update Interval**: How often to check UPS status (1-60 seconds, default: 5)

### Display Settings
- **Show Battery Percentage**: Display battery charge on the bar widget
- **Show Load Percentage**: Display UPS load instead of battery percentage

### Appearance
- **Widget Icon**: Customize the icon shown when UPS is online
  - Default: `battery-charging`
  - Automatically changes to battery level icons when on battery power

### Alert Thresholds
- **Warning Battery Level**: Show warning color when battery drops below this level (default: 50%)
- **Critical Battery Level**: Show critical/error color when battery drops below this level (default: 20%)

## Usage

### Bar Widget
- **Left Click**: Open detailed panel view
- **Right Click**: Open context menu
  - Refresh: Manually update UPS status
  - Settings: Open settings dialog

### Panel View
- View all detailed UPS information
- Battery and load progress bars
- Click refresh button to update immediately
- Scrollable additional information section

### Tooltip
Hover over the widget to see:
- Current UPS status
- Battery charge percentage
- Load percentage
- Runtime remaining
- Last update time

## Understanding UPS Status

- **ONLINE**: UPS is online and running on line power
- **ONBATT**: UPS is running on battery power (power outage)
- **CHARGING**: UPS battery is charging
- **COMMLOST**: Communication with UPS lost
- **SHUTTING DOWN**: UPS is shutting down
- **UNAVAILABLE**: apcupsd is not running or UPS not connected

## Troubleshooting

### Widget shows "UPS Unavailable"
1. Check if apcupsd is running: `systemctl status apcupsd`
2. Start apcupsd: `sudo systemctl start apcupsd`
3. Verify UPS is connected: `apcaccess status`
4. Check apcupsd configuration: `/etc/apcupsd/apcupsd.conf`

### No data appearing
1. Ensure your user has permission to run `apcaccess`
2. Try running `apcaccess status` in terminal
3. Check apcupsd logs: `journalctl -u apcupsd`

### USB connection issues
1. Check USB cable connection
2. Verify USB device is recognized: `lsusb | grep APC`
3. May need to configure DEVICE in `/etc/apcupsd/apcupsd.conf`

## Technical Details

### Data Source
The plugin executes `apcaccess status` which communicates with the apcupsd daemon (typically on port 3551) to retrieve UPS information.

### Update Mechanism
- Timer-based polling (configurable interval)
- Parses key-value pairs from apcaccess output
- Extracts and displays critical metrics
- Stores full data for comprehensive panel view

### Key Metrics Displayed
- **BCHARGE**: Battery charge percentage
- **LOADPCT**: Load on UPS (percentage of capacity)
- **TIMELEFT**: Estimated runtime on battery
- **LINEV**: Input line voltage
- **STATUS**: Current UPS operational status
- **MODEL**: UPS model
- Plus all other data provided by apcupsd

## License

MIT License - See LICENSE file for details

## Author

NekoShinobi

## Repository

https://github.com/NekoShinobi/noctalia-plugins

## Version

1.0.0
