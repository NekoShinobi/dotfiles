import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  property var pluginApi: null

  readonly property int hoursToMillis: 3_600_000

  readonly property int updateIntervalHours: pluginApi?.pluginSettings.updateIntervalHours || pluginApi?.manifest?.metadata.defaultSettings?.updateIntervalHours || 4
  readonly property string terminalCommand: pluginApi?.pluginSettings.terminalCommand || pluginApi?.manifest?.metadata.defaultSettings?.terminalCommand || "foot -e"
  readonly property bool autoRefreshOnOpen: pluginApi?.pluginSettings.autoRefreshOnOpen ?? pluginApi?.manifest?.metadata.defaultSettings?.autoRefreshOnOpen ?? true

  property int updateCount: 0
  property var packageList: []
  property bool isChecking: false
  property string lastCheckTime: ""
  property var tempPackageList: [] // Temporary storage before repo detection

  Component.onCompleted: {
    Logger.i("YayUpdater", "Plugin initialized");
    startCheckUpdates();
  }

  //
  // ------ Check for updates ------
  //
  Timer {
    id: timerCheckUpdates

    interval: root.updateIntervalHours * root.hoursToMillis
    running: true
    repeat: true
    onTriggered: root.startCheckUpdates()
  }

  function startCheckUpdates() {
    Logger.i("YayUpdater", "Checking for updates...");
    root.isChecking = true;
    checkUpdatesProc.running = true;
  }

  Process {
    id: checkUpdatesProc
    command: ["sh", "-c", "(checkupdates 2>/dev/null; yay -Qua 2>/dev/null)"]

    stdout: StdioCollector {
      onStreamFinished: {
        const output = text.trim();

        if (output === "") {
          root.updateCount = 0;
          root.packageList = [];
          root.tempPackageList = [];
          Logger.i("YayUpdater", "No updates available");
          root.lastCheckTime = new Date().toLocaleTimeString();
          root.isChecking = false;
        } else {
          const lines = output.split('\n').filter(line => line.trim() !== "");
          const packages = lines.map(line => {
            const parts = line.split(/\s+/);
            const name = parts[0] || "";
            
            return {
              repository: "unknown",
              name: name,
              fullName: name,
              currentVersion: parts[1] || "",
              newVersion: parts[3] || parts[2] || ""
            };
          });

          // Sort packages alphabetically by name
          packages.sort((a, b) => a.name.localeCompare(b.name));

          root.tempPackageList = packages;
          root.updateCount = packages.length;
          Logger.i("YayUpdater", `Found ${root.updateCount} updates, detecting repositories...`);
          
          // Trigger repository detection
          root.detectRepositories();
        }
      }
    }

    onExited: function (exitCode, exitStatus) {
      if (exitCode !== 0) {
        Logger.e("YayUpdater", `Check updates failed with exit code ${exitCode}`);
        root.isChecking = false;
      }
    }
  }

  //
  // ------ Detect package repositories ------
  //
  function detectRepositories() {
    if (root.tempPackageList.length === 0) {
      root.packageList = [];
      root.lastCheckTime = new Date().toLocaleTimeString();
      root.isChecking = false;
      return;
    }

    const packageNames = root.tempPackageList.map(pkg => pkg.name).join(" ");
    repoDetectProc.command = ["sh", "-c", `yay -Si ${packageNames} 2>/dev/null`];
    repoDetectProc.running = true;
  }

  Process {
    id: repoDetectProc

    stdout: StdioCollector {
      onStreamFinished: {
        const output = text.trim();
        const repoMap = {}; // Map package name to repository

        if (output !== "") {
          // Parse yay -Si output
          // Format: Multiple blocks separated by blank lines
          // Each block has: Repository : <repo> ... Name : <package>
          const blocks = output.split(/\n\n+/);
          
          blocks.forEach(block => {
            const lines = block.split('\n');
            let currentRepo = "unknown";
            let currentName = "";

            lines.forEach(line => {
              const repoMatch = line.match(/^Repository\s*:\s*(.+)$/i);
              const nameMatch = line.match(/^Name\s*:\s*(.+)$/i);

              if (repoMatch) {
                currentRepo = repoMatch[1].trim();
              } else if (nameMatch) {
                currentName = nameMatch[1].trim();
              }
            });

            if (currentName) {
              repoMap[currentName] = currentRepo;
            }
          });
        }

        // Update packages with repository information
        const updatedPackages = root.tempPackageList.map(pkg => {
          return {
            repository: repoMap[pkg.name] || "unknown",
            name: pkg.name,
            fullName: pkg.fullName,
            currentVersion: pkg.currentVersion,
            newVersion: pkg.newVersion
          };
        });

        root.packageList = updatedPackages;
        
        const repoCount = Object.keys(repoMap).length;
        Logger.i("YayUpdater", `Repository detection complete: ${repoCount}/${root.tempPackageList.length} packages identified`);
        
        root.lastCheckTime = new Date().toLocaleTimeString();
        root.isChecking = false;
      }
    }

    onExited: function (exitCode, exitStatus) {
      if (exitCode !== 0) {
        Logger.w("YayUpdater", `Repository detection failed with exit code ${exitCode}, using unknown`);
        // Fallback: use packages without repository info
        root.packageList = root.tempPackageList;
        root.lastCheckTime = new Date().toLocaleTimeString();
        root.isChecking = false;
      }
    }
  }

  //
  // ------ Run system update ------
  //
  function runSystemUpdate() {
    const updateCmd = "yay -Syu";
    const term = root.terminalCommand.trim();
    const fullCmd = (term.indexOf("{}") !== -1)
      ? term.replace("{}", updateCmd)
      : term + " " + updateCmd;

    Logger.i("YayUpdater", `Running update command: ${fullCmd}`);

    systemUpdateProc.command = ["sh", "-c", fullCmd];
    systemUpdateProc.running = true;
  }

  Process {
    id: systemUpdateProc

    onExited: function (exitCode, exitStatus) {
      if (exitCode === 0) {
        Logger.i("YayUpdater", "Update command completed");
        // Refresh the update list after update completes
        Qt.callLater(root.startCheckUpdates);
      } else {
        Logger.w("YayUpdater", `Update command exited with code ${exitCode}`);
      }
    }
  }

  //
  // ------ IPC ------
  //
  IpcHandler {
    target: "plugin:yay-updater"

    function check(): void {
      root.startCheckUpdates();
    }

    function update(): void {
      root.runSystemUpdate();
    }
  }
}
