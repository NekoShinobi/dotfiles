import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  property var pluginApi: null

  readonly property int updateIntervalSeconds: pluginApi?.pluginSettings.updateIntervalSeconds || pluginApi?.manifest?.metadata.defaultSettings?.updateIntervalSeconds || 5
  readonly property int warnBatteryPercent: pluginApi?.pluginSettings.warnBatteryPercent || pluginApi?.manifest?.metadata.defaultSettings?.warnBatteryPercent || 50
  readonly property int criticalBatteryPercent: pluginApi?.pluginSettings.criticalBatteryPercent || pluginApi?.manifest?.metadata.defaultSettings?.criticalBatteryPercent || 20

  // UPS Data properties
  property string status: "UNKNOWN"
  property real batteryCharge: 0.0
  property real loadPercent: 0.0
  property real loadWatts: 0.0
  property string timeLeft: "N/A"
  property string lineVoltage: "N/A"
  property string model: "Unknown"
  property string upsName: "UPS"
  property bool isOnline: false
  property bool isCharging: false
  property bool isBatteryBackup: false
  property bool isAvailable: false
  property string lastUpdateTime: ""

  // Full data for panel display
  property var fullData: ({})

  Component.onCompleted: {
    Logger.i("ApcUpsd", "Plugin initialized");
    updateUpsStatus();
  }

  //
  // ------ Timer for periodic updates ------
  //
  Timer {
    id: updateTimer
    interval: root.updateIntervalSeconds * 1000
    running: true
    repeat: true
    onTriggered: root.updateUpsStatus()
  }

  //
  // ------ Fetch UPS status ------
  //
  function updateUpsStatus() {
    apcaccessProc.running = true;
  }

  Process {
    id: apcaccessProc
    command: ["apcaccess", "status"]

    stdout: StdioCollector {
      onStreamFinished: {
        const output = text.trim();
        
        if (output === "") {
          Logger.w("ApcUpsd", "No output from apcaccess - UPS may not be available");
          root.isAvailable = false;
          root.status = "UNAVAILABLE";
          return;
        }

        parseApcOutput(output);
      }
    }

    onExited: function (exitCode, exitStatus) {
      if (exitCode !== 0) {
        Logger.e("ApcUpsd", `apcaccess failed with exit code ${exitCode}`);
        root.isAvailable = false;
        root.status = "ERROR";
      }
    }
  }

  //
  // ------ Parse apcaccess output ------
  //
  function parseApcOutput(output) {
    const lines = output.split('\n');
    const data = {};

    // Parse key-value pairs
    lines.forEach(line => {
      const match = line.match(/^([A-Z]+)\s*:\s*(.+)$/);
      if (match) {
        const key = match[1].trim();
        const value = match[2].trim();
        data[key] = value;
      }
    });

    root.fullData = data;
    root.isAvailable = true;

    // Extract key values
    root.status = data['STATUS'] || 'UNKNOWN';
    root.model = data['MODEL'] || 'Unknown';
    root.upsName = data['UPSNAME'] || 'UPS';

    // Parse battery charge (remove "Percent" suffix)
    const chargeMatch = (data['BCHARGE'] || '0').match(/([\d.]+)/);
    root.batteryCharge = chargeMatch ? parseFloat(chargeMatch[1]) : 0.0;

    // Parse load percent
    const loadMatch = (data['LOADPCT'] || '0').match(/([\d.]+)/);
    root.loadPercent = loadMatch ? parseFloat(loadMatch[1]) : 0.0;

    // Parse load watts (NOMPOWER or calculated from LOADPCT)
    const wattsMatch = (data['NOMPOWER'] || '0').match(/([\d.]+)/);
    const nomPower = wattsMatch ? parseFloat(wattsMatch[1]) : 0.0;
    root.loadWatts = nomPower > 0 ? (root.loadPercent / 100) * nomPower : 0.0;

    // Time left
    root.timeLeft = data['TIMELEFT'] || 'N/A';

    // Line voltage
    root.lineVoltage = data['LINEV'] || 'N/A';

    // Determine status flags
    root.isOnline = root.status.indexOf('ONLINE') !== -1;
    root.isCharging = root.status.indexOf('CHARGING') !== -1;
    root.isBatteryBackup = root.status.indexOf('ONBATT') !== -1 || root.status.indexOf('ONBATTERY') !== -1;

    root.lastUpdateTime = new Date().toLocaleTimeString();

    Logger.i("ApcUpsd", `UPS Status: ${root.status}, Battery: ${root.batteryCharge}%, Load: ${root.loadPercent}%`);
  }

  //
  // ------ IPC ------
  //
  IpcHandler {
    target: "plugin:apcupsd"

    function refresh(): void {
      root.updateUpsStatus();
    }
  }
}
