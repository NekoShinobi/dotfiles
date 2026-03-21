import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property bool hovered: false

  // Bar positioning properties
  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property real barHeight: Style.getBarHeightForScreen(screenName)
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  // Settings
  property string iconName: pluginApi?.pluginSettings?.iconName || pluginApi?.manifest?.metadata?.defaultSettings?.iconName || "battery-charging"
  property bool showPercentage: pluginApi?.pluginSettings?.showPercentage ?? pluginApi?.manifest?.metadata?.defaultSettings?.showPercentage ?? true
  property bool showLoad: pluginApi?.pluginSettings?.showLoad ?? pluginApi?.manifest?.metadata?.defaultSettings?.showLoad ?? false
  property int warnBatteryPercent: pluginApi?.pluginSettings?.warnBatteryPercent || pluginApi?.manifest?.metadata?.defaultSettings?.warnBatteryPercent || 50
  property int criticalBatteryPercent: pluginApi?.pluginSettings?.criticalBatteryPercent || pluginApi?.manifest?.metadata?.defaultSettings?.criticalBatteryPercent || 20

  // UPS Status from Main.qml
  readonly property bool isAvailable: root.pluginApi?.mainInstance?.isAvailable || false
  readonly property string status: root.pluginApi?.mainInstance?.status || "UNKNOWN"
  readonly property real batteryCharge: root.pluginApi?.mainInstance?.batteryCharge || 0.0
  readonly property real loadPercent: root.pluginApi?.mainInstance?.loadPercent || 0.0
  readonly property real loadWatts: root.pluginApi?.mainInstance?.loadWatts || 0.0
  readonly property string lineVoltage: root.pluginApi?.mainInstance?.lineVoltage || "N/A"
  readonly property bool isOnline: root.pluginApi?.mainInstance?.isOnline || false
  readonly property bool isBatteryBackup: root.pluginApi?.mainInstance?.isBatteryBackup || false

  // Display properties
  readonly property string displayText: {
    if (!isAvailable) return "N/A";
    if (showLoad) {
      const percent = Math.round(loadPercent) + "%";
      const watts = Math.round(loadWatts);
      return watts > 0 ? percent + " (" + watts + "W)" : percent;
    }
    if (showPercentage) return Math.round(batteryCharge) + "%";
    return "";
  }

  readonly property color statusColor: {
    if (!isAvailable) return Color.mOnSurfaceVariant;
    if (isBatteryBackup) {
      if (batteryCharge <= criticalBatteryPercent) return Color.mError;
      if (batteryCharge <= warnBatteryPercent) return Color.mSecondary;
      return Color.mPrimary;
    }
    return Color.mOnSurface;
  }

  readonly property string currentIcon: {
    if (!isAvailable) return "battery-exclamation";
    if (isBatteryBackup) {
      if (batteryCharge <= 25) return "battery-1";
      if (batteryCharge <= 50) return "battery-2";
      if (batteryCharge <= 75) return "battery-3";
      return "battery-4";
    }
    return iconName;
  }

  readonly property real contentWidth: isVertical ? capsuleHeight : layout.implicitWidth + Style.marginS * 2
  readonly property real contentHeight: isVertical ? layout.implicitHeight + Style.marginS * 2 : capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  //
  // ------ Widget ------
  //
  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    color: root.hovered ? Color.mHover : Style.capsuleColor
    radius: Style.radiusM
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    Item {
      id: layout
      anchors.centerIn: parent

      implicitWidth: grid.implicitWidth
      implicitHeight: grid.implicitHeight

      GridLayout {
        id: grid
        columns: root.isVertical ? 1 : 2
        rowSpacing: Style.marginS
        columnSpacing: Style.marginS

        NIcon {
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          icon: root.currentIcon
          color: root.hovered ? Color.mOnHover : root.statusColor
        }

        NText {
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          text: root.displayText
          color: root.hovered ? Color.mOnHover : root.statusColor
          pointSize: root.barFontSize
          visible: root.displayText !== ""
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: function (mouse) {
      if (mouse.button === Qt.LeftButton) {
        if (pluginApi) {
          pluginApi.openPanel(root.screen, root);
        }
      } else if (mouse.button === Qt.RightButton) {
        PanelService.showContextMenu(contextMenu, root, screen);
      }
    }

    onEntered: {
      root.hovered = true;
      buildTooltip();
    }

    onExited: {
      root.hovered = false;
      TooltipService.hide();
    }

    function buildTooltip() {
      const lines = [];

      if (!root.isAvailable) {
        lines.push("UPS Unavailable");
        lines.push("Check that apcupsd is installed and running");
      } else {
        lines.push(`Charge: ${Math.round(root.batteryCharge)}%`);
        lines.push(`Voltage: ${root.lineVoltage}`);
        lines.push(`Load: ${Math.round(root.loadPercent)}%`);
      }

      lines.push("\nLeft click: View details");
      lines.push("Right click: Menu");

      TooltipService.show(lines.join("\n"));
    }
  }

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": "Refresh",
        "action": "refresh",
        "icon": "refresh"
      },
      {
        "label": "Widget Settings",
        "action": "settings",
        "icon": "settings"
      },
    ]

    onTriggered: function (action) {
      contextMenu.close();
      PanelService.closeContextMenu(screen);

      if (action === "refresh") {
        if (root.pluginApi?.mainInstance) {
          root.pluginApi.mainInstance.updateUpsStatus();
        }
      } else if (action === "settings") {
        BarService.openPluginSettings(root.screen, pluginApi.manifest);
      }
    }
  }
}
