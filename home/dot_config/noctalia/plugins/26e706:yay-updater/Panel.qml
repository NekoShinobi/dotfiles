import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  readonly property var mainInstance: pluginApi?.mainInstance
  readonly property var geometryPlaceholder: panelContainer
  property real contentPreferredWidth: 420 * Style.uiScaleRatio
  property real contentPreferredHeight: 520 * Style.uiScaleRatio
  readonly property bool allowAttach: true

  readonly property int updateCount: mainInstance?.updateCount || 0
  readonly property var packageList: mainInstance?.packageList || []
  readonly property bool isChecking: mainInstance?.isChecking || false
  readonly property string lastCheckTime: mainInstance?.lastCheckTime || ""
  readonly property bool autoRefreshOnOpen: pluginApi?.pluginSettings?.autoRefreshOnOpen ?? true

  anchors.fill: parent

  Component.onCompleted: {
    if (autoRefreshOnOpen && mainInstance) {
      mainInstance.startCheckUpdates();
    }
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      anchors {
        fill: parent
        margins: Style.marginL
      }
      spacing: Style.marginL

      // Header
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NText {
          text: "Yay Updates"
          font.pointSize: Style.fontSizeL * Style.uiScaleRatio
          font.weight: Font.Bold
          color: Color.mOnSurface
          Layout.fillWidth: true
        }

        NButton {
          text: "Refresh"
          icon: "refresh"
          enabled: !root.isChecking
          onClicked: {
            if (root.mainInstance) {
              root.mainInstance.startCheckUpdates();
            }
          }
        }
      }

      // Status info
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: statusLayout.implicitHeight + Style.marginM * 2
        color: Color.mSurfaceVariant
        radius: Style.radiusL

        ColumnLayout {
          id: statusLayout
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Style.marginM
          }
          spacing: Style.marginS

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            NIcon {
              icon: root.isChecking ? "loader" : (root.updateCount > 0 ? "alert-circle" : "check")
              pointSize: Style.fontSizeXL * Style.uiScaleRatio
              color: root.updateCount > 0 ? Color.mPrimary : Color.mOnSurfaceVariant
              Layout.alignment: Qt.AlignVCenter

              RotationAnimation on rotation {
                running: root.isChecking
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              NText {
                text: root.isChecking
                  ? "Checking for updates..."
                  : (root.updateCount > 0
                    ? `${root.updateCount} update${root.updateCount !== 1 ? 's' : ''} available`
                    : "System is up to date")
                font.pointSize: Style.fontSizeM * Style.uiScaleRatio
                font.weight: Font.DemiBold
                color: Color.mOnSurface
              }

              NText {
                text: root.lastCheckTime ? `Last checked: ${root.lastCheckTime}` : ""
                font.pointSize: Style.fontSizeS * Style.uiScaleRatio
                color: Color.mOnSurfaceVariant
                visible: root.lastCheckTime !== ""
              }
            }
          }

          NButton {
            Layout.fillWidth: true
            text: "Update Now"
            icon: "download"
            enabled: root.updateCount > 0 && !root.isChecking
            visible: root.updateCount > 0
            onClicked: {
              if (root.mainInstance) {
                root.mainInstance.runSystemUpdate();
              }
            }
          }
        }
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Color.mOutline
        opacity: 0.3
        visible: root.updateCount > 0
      }

      // Package list header
      NText {
        text: "Available Updates"
        font.pointSize: Style.fontSizeM * Style.uiScaleRatio
        font.weight: Font.DemiBold
        color: Color.mOnSurface
        visible: root.updateCount > 0
      }

      // Scrollable package list
      ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.updateCount > 0
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ListView {
          id: packageListView
          model: root.packageList
          spacing: Style.marginS

          delegate: Rectangle {
            width: packageListView.width
            height: packageItemLayout.implicitHeight + Style.marginM * 2
            color: Color.mSurface
            radius: Style.radiusM
            border.color: Color.mOutline
            border.width: 1

            ColumnLayout {
              id: packageItemLayout
              anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Style.marginM
                rightMargin: Style.marginM
              }
              spacing: 4

              RowLayout {
                spacing: Style.marginS

                Rectangle {
                  visible: modelData.repository !== "unknown"
                  Layout.preferredWidth: repoText.implicitWidth + Style.marginS * 2
                  Layout.preferredHeight: repoText.implicitHeight + 4
                  color: modelData.repository === "aur" ? Color.mSecondary : Color.mPrimary
                  radius: Style.radiusS
                  opacity: 0.2

                  NText {
                    id: repoText
                    anchors.centerIn: parent
                    text: modelData.repository || "unknown"
                    font.pointSize: Style.fontSizeXS * Style.uiScaleRatio
                    font.weight: Font.Bold
                    color: modelData.repository === "aur" ? Color.mSecondary : Color.mPrimary
                  }
                }

                NText {
                  text: modelData.name
                  font.pointSize: Style.fontSizeM * Style.uiScaleRatio
                  font.weight: Font.DemiBold
                  color: Color.mOnSurface
                  Layout.fillWidth: true
                }
              }

              RowLayout {
                spacing: Style.marginS

                NText {
                  text: modelData.currentVersion
                  font.pointSize: Style.fontSizeS * Style.uiScaleRatio
                  color: Color.mOnSurfaceVariant
                }

                NIcon {
                  icon: "arrow-right"
                  pointSize: Style.fontSizeS * Style.uiScaleRatio
                  color: Color.mOnSurfaceVariant
                }

                NText {
                  text: modelData.newVersion
                  font.pointSize: Style.fontSizeS * Style.uiScaleRatio
                  color: Color.mPrimary
                  font.weight: Font.DemiBold
                }
              }
            }
          }
        }
      }

      // Empty state when no updates
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.updateCount === 0 && !root.isChecking

        ColumnLayout {
          anchors.centerIn: parent
          spacing: Style.marginM

          NIcon {
            Layout.alignment: Qt.AlignHCenter
            icon: "check"
            pointSize: Style.fontSizeXXL * 2 * Style.uiScaleRatio
            color: Color.mOnSurfaceVariant
          }

          NText {
            Layout.alignment: Qt.AlignHCenter
            text: "No updates available"
            font.pointSize: Style.fontSizeL * Style.uiScaleRatio
            color: Color.mOnSurfaceVariant
          }
        }
      }
    }
  }
}
