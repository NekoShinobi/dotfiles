import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Rectangle {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""

  readonly property var mainInstance: pluginApi?.mainInstance

  // UPS Data
  readonly property bool isAvailable: mainInstance?.isAvailable || false
  readonly property string status: mainInstance?.status || "UNKNOWN"
  readonly property string model: mainInstance?.model || "Unknown"
  readonly property string upsName: mainInstance?.upsName || "UPS"
  readonly property real batteryCharge: mainInstance?.batteryCharge || 0.0
  readonly property real loadPercent: mainInstance?.loadPercent || 0.0
  readonly property string timeLeft: mainInstance?.timeLeft || "N/A"
  readonly property string lineVoltage: mainInstance?.lineVoltage || "N/A"
  readonly property bool isOnline: mainInstance?.isOnline || false
  readonly property bool isBatteryBackup: mainInstance?.isBatteryBackup || false
  readonly property var fullData: mainInstance?.fullData || ({})

  width: 400
  height: 600
  color: Color.mSurface
  radius: Style.radiusL

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.marginL
    spacing: Style.marginL

    //
    // ------ Header ------
    //
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NIcon {
        icon: root.isBatteryBackup ? "battery-exclamation" : "battery-charging"
        pointSize: Style.fontSizeXL * Style.uiScaleRatio
        color: root.isBatteryBackup ? Color.mSecondary : Color.mPrimary
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginXS

        NText {
          text: root.upsName
          font.pointSize: Style.fontSizeL * Style.uiScaleRatio
          font.weight: Font.DemiBold
          color: Color.mOnSurface
        }

        NText {
          text: root.model
          font.pointSize: Style.fontSizeM * Style.uiScaleRatio
          color: Color.mOnSurfaceVariant
        }
      }

      NButton {
        icon: "refresh"
        onClicked: {
          if (root.mainInstance) {
            root.mainInstance.updateUpsStatus();
          }
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Color.mOutline
      opacity: 0.3
    }

    //
    // ------ Status Section ------
    //
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NText {
        text: "Status"
        font.pointSize: Style.fontSizeL * Style.uiScaleRatio
        font.weight: Font.DemiBold
        color: Color.mOnSurface
      }

      // Status Badge
      Rectangle {
        Layout.fillWidth: true
        height: 60
        color: root.isOnline ? (Settings.data.colorSchemes.darkMode ? Color.mSurfaceContainer : Color.mSurfaceContainerHigh) : Color.mErrorContainer
        radius: Style.radiusM

        RowLayout {
          anchors.centerIn: parent
          spacing: Style.marginM

          NIcon {
            icon: root.isOnline ? "plug" : "plug-off"
            pointSize: Style.fontSizeL * Style.uiScaleRatio
            color: root.isOnline ? Color.mPrimary : Color.mError
          }

          NText {
            text: root.status
            font.pointSize: Style.fontSizeL * Style.uiScaleRatio
            font.weight: Font.DemiBold
            color: root.isOnline ? Color.mOnSurface : Color.mError
          }
        }
      }
    }

    //
    // ------ Battery Section ------
    //
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NText {
        text: "Battery"
        font.pointSize: Style.fontSizeL * Style.uiScaleRatio
        font.weight: Font.DemiBold
        color: Color.mOnSurface
      }

      // Battery Level Bar
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        RowLayout {
          Layout.fillWidth: true

          NText {
            text: "Charge"
            color: Color.mOnSurfaceVariant
          }

          Item { Layout.fillWidth: true }

          NText {
            text: Math.round(root.batteryCharge) + "%"
            font.weight: Font.Bold
            color: Color.mOnSurface
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 24
          color: Color.mSurfaceVariant
          radius: Style.radiusS

          Rectangle {
            width: parent.width * (root.batteryCharge / 100)
            height: parent.height
            color: {
              if (root.batteryCharge <= 20) return Color.mError;
              if (root.batteryCharge <= 50) return Color.mSecondary;
              return Color.mPrimary;
            }
            radius: Style.radiusS
          }
        }
      }

      // Runtime
      InfoRow {
        label: "Runtime Remaining"
        value: root.timeLeft
      }
    }

    //
    // ------ Power Section ------
    //
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NText {
        text: "Power"
        font.pointSize: Style.fontSizeL * Style.uiScaleRatio
        font.weight: Font.DemiBold
        color: Color.mOnSurface
      }

      InfoRow {
        label: "Line Voltage"
        value: root.lineVoltage
      }

      // Load Bar
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        RowLayout {
          Layout.fillWidth: true

          NText {
            text: "Load"
            color: Color.mOnSurfaceVariant
          }

          Item { Layout.fillWidth: true }

          NText {
            text: Math.round(root.loadPercent) + "%"
            font.weight: Font.Bold
            color: Color.mOnSurface
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 24
          color: Color.mSurfaceVariant
          radius: Style.radiusS

          Rectangle {
            width: parent.width * (root.loadPercent / 100)
            height: parent.height
            color: Color.mSecondary
            radius: Style.radiusS
          }
        }
      }
    }

    //
    // ------ Additional Info (collapsible) ------
    //
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Style.marginM

      NText {
        text: "Additional Information"
        font.pointSize: Style.fontSizeL * Style.uiScaleRatio
        font.weight: Font.DemiBold
        color: Color.mOnSurface
      }

      ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
          width: parent.width
          spacing: Style.marginS

          Repeater {
            model: {
              const keys = Object.keys(root.fullData).filter(key => {
                // Filter out keys we already displayed
                return !['STATUS', 'MODEL', 'UPSNAME', 'BCHARGE', 'LOADPCT', 'TIMELEFT', 'LINEV'].includes(key);
              }).sort();
              return keys;
            }

            InfoRow {
              label: modelData
              value: root.fullData[modelData] || "N/A"
            }
          }
        }
      }
    }

    Item {
      Layout.fillHeight: true
    }
  }

  // Info Row Component
  component InfoRow: RowLayout {
    property string label: ""
    property string value: ""

    Layout.fillWidth: true
    spacing: Style.marginM

    NText {
      text: label
      color: Color.mOnSurfaceVariant
    }

    Item { Layout.fillWidth: true }

    NText {
      text: value
      font.weight: Font.Medium
      color: Color.mOnSurface
    }
  }

  // Unavailable state
  ColumnLayout {
    anchors.centerIn: parent
    spacing: Style.marginM
    visible: !root.isAvailable

    NIcon {
      Layout.alignment: Qt.AlignHCenter
      icon: "alert-circle"
      pointSize: Style.fontSizeXXL * 2 * Style.uiScaleRatio
      color: Color.mOnSurfaceVariant
    }

    NText {
      Layout.alignment: Qt.AlignHCenter
      text: "UPS Unavailable"
      font.pointSize: Style.fontSizeL * Style.uiScaleRatio
      color: Color.mOnSurfaceVariant
    }

    NText {
      Layout.alignment: Qt.AlignHCenter
      text: "Check that apcupsd is installed and running"
      font.pointSize: Style.fontSizeM * Style.uiScaleRatio
      color: Color.mOnSurfaceVariant
    }

    NButton {
      Layout.alignment: Qt.AlignHCenter
      text: "Retry"
      icon: "refresh"
      onClicked: {
        if (root.mainInstance) {
          root.mainInstance.updateUpsStatus();
        }
      }
    }
  }
}
