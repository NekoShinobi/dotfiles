import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property int updateIntervalHours: cfg.updateIntervalHours ?? defaults.updateIntervalHours ?? 4
  property string terminalCommand: cfg.terminalCommand ?? defaults.terminalCommand ?? "foot -e"
  property string iconName: cfg.iconName ?? defaults.iconName ?? "download"
  property bool hideOnZero: cfg.hideOnZero ?? defaults.hideOnZero ?? false
  property bool autoRefreshOnOpen: cfg.autoRefreshOnOpen ?? defaults.autoRefreshOnOpen ?? true

  spacing: Style.marginL

  Component.onCompleted: {
    Logger.i("YayUpdater", "Settings UI loaded");
  }

  //
  // ------ General Settings ------
  //
  NText {
    text: "General Settings"
    pointSize: Style.fontSizeL
    font.weight: Font.DemiBold
    color: Color.mOnSurface
  }

  NToggle {
    id: hideWidget
    label: "Hide widget when no updates"
    description: "Hide the bar widget when there are no updates available"
    checked: root.hideOnZero
    onToggled: function (checked) {
      root.hideOnZero = checked;
      root.saveSettings();
    }
  }

  NToggle {
    id: autoRefresh
    label: "Auto-refresh on panel open"
    description: "Automatically check for updates when opening the panel"
    checked: root.autoRefreshOnOpen
    onToggled: function (checked) {
      root.autoRefreshOnOpen = checked;
      root.saveSettings();
    }
  }

  Rectangle {
    Layout.fillWidth: true
    height: 1
    color: Color.mOutline
    opacity: 0.3
  }

  //
  // ------ Icon Settings ------
  //
  NText {
    text: "Appearance"
    pointSize: Style.fontSizeL
    font.weight: Font.DemiBold
    color: Color.mOnSurface
  }

  RowLayout {
    spacing: Style.marginL

    NLabel {
      label: "Widget Icon"
      description: "Icon displayed on the bar widget"
    }

    NText {
      text: root.iconName
      color: Settings.data.colorSchemes.darkMode ? Color.mPrimary : Color.mOnPrimary
    }

    NIcon {
      icon: root.iconName
      color: Settings.data.colorSchemes.darkMode ? Color.mPrimary : Color.mOnPrimary
    }

    NButton {
      text: "Change Icon"
      onClicked: {
        Logger.i("YayUpdater", "Icon selector button clicked.");
        changeIcon.open();
      }
    }

    NIconPicker {
      id: changeIcon
      onIconSelected: function (icon) {
        root.iconName = icon;
        root.saveSettings();
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
  // ------ Update Interval ------
  //
  NText {
    text: "Update Check Interval"
    pointSize: Style.fontSizeL
    font.weight: Font.DemiBold
    color: Color.mOnSurface
  }

  ColumnLayout {
    spacing: Style.marginM

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NLabel {
        label: "Check Interval"
        description: "How often to check for updates (in hours)"
      }

      NText {
        text: root.updateIntervalHours.toString() + " hour" + (root.updateIntervalHours !== 1 ? "s" : "")
        color: Settings.data.colorSchemes.darkMode ? Color.mOnSurface : Color.mOnPrimary
      }
    }

    NSlider {
      Layout.fillWidth: true
      from: 1
      to: 24
      value: root.updateIntervalHours
      stepSize: 1
      onValueChanged: {
        root.updateIntervalHours = value;
      }
      onPressedChanged: {
        if (!pressed) {
          root.saveSettings();
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
  // ------ Terminal Command ------
  //
  NText {
    text: "Terminal Settings"
    pointSize: Style.fontSizeL
    font.weight: Font.DemiBold
    color: Color.mOnSurface
  }

  ColumnLayout {
    spacing: Style.marginS

    NLabel {
      label: "Terminal Command"
      description: "Terminal emulator to use for running updates. Use {} as placeholder for the command."
    }

    NTextInput {
      Layout.fillWidth: true
      label: "Terminal Command"
      placeholderText: "foot -e"
      text: root.terminalCommand
      onTextChanged: {
        root.terminalCommand = text;
        root.saveSettings();
      }
    }

    NText {
      text: "Examples:\n  • foot -e\n  • kitty -e\n  • alacritty -e\n  • konsole -e"
      pointSize: Style.fontSizeS
      color: Color.mOnSurfaceVariant
      lineHeight: 1.4
    }
  }

  Rectangle {
    Layout.fillWidth: true
    height: 1
    color: Color.mOutline
    opacity: 0.3
  }

  //
  // ------ Manual Actions ------
  //
  NText {
    text: "Actions"
    pointSize: Style.fontSizeL
    font.weight: Font.DemiBold
    color: Color.mOnSurface
  }

  RowLayout {
    spacing: Style.marginM

    NButton {
      text: "Check Now"
      icon: "refresh"
      onClicked: {
        if (root.pluginApi?.mainInstance) {
          root.pluginApi.mainInstance.startCheckUpdates();
        }
      }
    }

    NButton {
      text: "Update System"
      icon: "download"
      enabled: (root.pluginApi?.mainInstance?.updateCount || 0) > 0
      onClicked: {
        if (root.pluginApi?.mainInstance) {
          root.pluginApi.mainInstance.runSystemUpdate();
        }
      }
    }
  }

  function saveSettings() {
    if (!pluginApi) {
      Logger.e("YayUpdater", "Cannot save settings: pluginApi is null");
      return;
    }

    pluginApi.pluginSettings.updateIntervalHours = root.updateIntervalHours;
    pluginApi.pluginSettings.terminalCommand = root.terminalCommand;
    pluginApi.pluginSettings.iconName = root.iconName;
    pluginApi.pluginSettings.hideOnZero = root.hideOnZero;
    pluginApi.pluginSettings.autoRefreshOnOpen = root.autoRefreshOnOpen;

    pluginApi.saveSettings();

    Logger.i("YayUpdater", "Settings saved successfully");
  }
}
