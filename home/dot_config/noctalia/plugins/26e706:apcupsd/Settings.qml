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

  property int updateIntervalSeconds: cfg.updateIntervalSeconds ?? defaults.updateIntervalSeconds ?? 5
  property string iconName: cfg.iconName ?? defaults.iconName ?? "battery-charging"
  property bool showPercentage: cfg.showPercentage ?? defaults.showPercentage ?? true
  property bool showLoad: cfg.showLoad ?? defaults.showLoad ?? false
  property int warnBatteryPercent: cfg.warnBatteryPercent ?? defaults.warnBatteryPercent ?? 50
  property int criticalBatteryPercent: cfg.criticalBatteryPercent ?? defaults.criticalBatteryPercent ?? 20

  spacing: Style.marginL

  Component.onCompleted: {
    Logger.i("ApcUpsd", "Settings UI loaded");
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

  ColumnLayout {
    spacing: Style.marginM

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NLabel {
        label: "Update Interval"
        description: "How often to check UPS status (in seconds)"
      }

      NText {
        text: root.updateIntervalSeconds.toString() + " second" + (root.updateIntervalSeconds !== 1 ? "s" : "")
        color: Settings.data.colorSchemes.darkMode ? Color.mOnSurface : Color.mOnPrimary
      }
    }

    NSlider {
      Layout.fillWidth: true
      from: 1
      to: 60
      value: root.updateIntervalSeconds
      stepSize: 1
      onValueChanged: {
        root.updateIntervalSeconds = value;
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
  // ------ Display Settings ------
  //
  NText {
    text: "Display"
    pointSize: Style.fontSizeL
    font.weight: Font.DemiBold
    color: Color.mOnSurface
  }

  NToggle {
    label: "Show Battery Percentage"
    description: "Display battery percentage on the bar widget"
    checked: root.showPercentage
    onToggled: function (checked) {
      root.showPercentage = checked;
      if (checked) root.showLoad = false;
      root.saveSettings();
    }
  }

  NToggle {
    label: "Show Load Percentage"
    description: "Display UPS load percentage instead of battery percentage"
    checked: root.showLoad
    onToggled: function (checked) {
      root.showLoad = checked;
      if (checked) root.showPercentage = false;
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
      description: "Icon displayed on the bar widget (when UPS is online)"
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
        Logger.i("ApcUpsd", "Icon selector button clicked.");
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
  // ------ Alert Thresholds ------
  //
  NText {
    text: "Alert Thresholds"
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
        label: "Warning Battery Level"
        description: "Show warning color when battery drops below this level"
      }

      NText {
        text: root.warnBatteryPercent.toString() + "%"
        color: Color.mSecondary
      }
    }

    NSlider {
      Layout.fillWidth: true
      from: 0
      to: 100
      value: root.warnBatteryPercent
      stepSize: 5
      onValueChanged: {
        root.warnBatteryPercent = value;
        // Ensure critical is below warning
        if (root.criticalBatteryPercent >= value) {
          root.criticalBatteryPercent = Math.max(0, value - 10);
        }
      }
      onPressedChanged: {
        if (!pressed) {
          root.saveSettings();
        }
      }
    }
  }

  ColumnLayout {
    spacing: Style.marginM

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NLabel {
        label: "Critical Battery Level"
        description: "Show critical/error color when battery drops below this level"
      }

      NText {
        text: root.criticalBatteryPercent.toString() + "%"
        color: Color.mError
      }
    }

    NSlider {
      Layout.fillWidth: true
      from: 0
      to: 100
      value: root.criticalBatteryPercent
      stepSize: 5
      onValueChanged: {
        root.criticalBatteryPercent = value;
        // Ensure critical is below warning
        if (value >= root.warnBatteryPercent) {
          root.warnBatteryPercent = Math.min(100, value + 10);
        }
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
  // ------ Actions ------
  //
  NText {
    text: "Actions"
    pointSize: Style.fontSizeL
    font.weight: Font.DemiBold
    color: Color.mOnSurface
  }

  NButton {
    text: "Refresh UPS Status"
    icon: "refresh"
    onClicked: {
      if (root.pluginApi?.mainInstance) {
        root.pluginApi.mainInstance.updateUpsStatus();
      }
    }
  }

  Item {
    Layout.fillHeight: true
  }

  //
  // ------ Save Settings Function ------
  //
  function saveSettings() {
    if (!pluginApi) return;

    pluginApi.pluginSettings = {
      updateIntervalSeconds: root.updateIntervalSeconds,
      iconName: root.iconName,
      showPercentage: root.showPercentage,
      showLoad: root.showLoad,
      warnBatteryPercent: root.warnBatteryPercent,
      criticalBatteryPercent: root.criticalBatteryPercent
    };

    pluginApi.saveSettings();
    Logger.i("ApcUpsd", "Settings saved");
  }
}
