import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: popup

  required property var shell
  required property var barWindow
  required property var battery
  required property bool anchorHovered
  required property int barHeight
  required property real popupX

  property bool open: false
  property bool popupHovered: popupHover.hovered
  property bool fadingOut: false

  function statNumber(name) {
    var value = Number(shell.batteryStats[name]);
    return isNaN(value) ? 0 : value;
  }

  function dismiss() {
    if (!open || fadingOut) return;
    fadingOut = true;
    closeTimer.stop();
    fadeOutTimer.restart();
  }

  function updateCloseTimer() {
    if (open && !anchorHovered && !popupHovered) {
      closeTimer.restart();
    } else {
      closeTimer.stop();
    }
  }

  function stateLabel() {
    var status = shell.batteryStats.status || "";
    if (status === "Full" || status === "Not charging") return "Fully charged";
    if (status.length > 0) return status;
    if (!battery || !battery.ready) return "Unavailable";
    switch (battery.state) {
    case UPowerDeviceState.Charging: return "Charging";
    case UPowerDeviceState.Discharging: return "Discharging";
    case UPowerDeviceState.FullyCharged: return "Fully charged";
    case UPowerDeviceState.Empty: return "Empty";
    case UPowerDeviceState.PendingCharge: return "Waiting to charge";
    case UPowerDeviceState.PendingDischarge: return "Waiting to discharge";
    default: return "Unknown";
    }
  }

  function formatDuration(seconds) {
    if (seconds <= 0) return "Not available";
    var hours = Math.floor(seconds / 3600);
    var minutes = Math.round((seconds % 3600) / 60);
    if (minutes === 60) {
      hours += 1;
      minutes = 0;
    }
    return hours > 0 ? hours + "h " + minutes + "m" : minutes + "m";
  }

  function estimateLabel() {
    var status = shell.batteryStats.status || "";
    var energy = statNumber("energy_now");
    var full = statNumber("energy_full");
    var power = statNumber("power_now");
    if (status === "Discharging" && power > 0) {
      return formatDuration(energy / power * 3600) + " remaining";
    }
    if (status === "Charging" && power > 0 && full > energy) {
      return formatDuration((full - energy) / power * 3600) + " to full";
    }
    if (status === "Full" || status === "Not charging") return "On AC power";
    if (!battery || !battery.ready) return "Not available";
    if (battery.state === UPowerDeviceState.Charging && battery.timeToFull > 0) {
      return formatDuration(battery.timeToFull) + " to full";
    }
    if (battery.state === UPowerDeviceState.Discharging && battery.timeToEmpty > 0) {
      return formatDuration(battery.timeToEmpty) + " remaining";
    }
    return "Not available";
  }

  function healthLabel() {
    var full = statNumber("energy_full");
    var design = statNumber("energy_full_design");
    if (full > 0 && design > 0) return Math.round(full / design * 100) + "%";
    if (!battery || !battery.healthSupported) return "Not available";
    var health = battery.healthPercentage <= 1 ? battery.healthPercentage * 100 : battery.healthPercentage;
    return Math.round(health) + "%";
  }

  function energyLabel() {
    var now = statNumber("energy_now") / 1000000;
    var full = statNumber("energy_full") / 1000000;
    if (now > 0 && full > 0) return now.toFixed(1) + " / " + full.toFixed(1) + " Wh";
    return battery.energy.toFixed(1) + " / " + battery.energyCapacity.toFixed(1) + " Wh";
  }

  function powerLabel() {
    return (statNumber("power_now") / 1000000).toFixed(1) + " W";
  }

  function voltageLabel() {
    var voltage = statNumber("voltage_now") / 1000000;
    return voltage > 0 ? voltage.toFixed(1) + " V" : "Not available";
  }

  function modelLabel() {
    var manufacturer = shell.batteryStats.manufacturer || "";
    var model = shell.batteryStats.model_name || "";
    var label = (manufacturer + " " + model).trim();
    return label.length > 0 ? label : "Not available";
  }

  visible: false
  grabFocus: true
  color: "transparent"
  implicitWidth: 310
  implicitHeight: content.implicitHeight + 24

  anchor.window: barWindow
  anchor.rect.x: popupX
  anchor.rect.y: barHeight + 8

  onOpenChanged: {
    if (open) {
      fadingOut = false;
      shell.refreshBatteryStats();
    }
    if (visible !== (open && battery && battery.ready)) {
      visible = open && battery && battery.ready;
    }
    updateCloseTimer();
  }
  onVisibleChanged: {
    if (!visible && open) {
      open = false;
      fadingOut = false;
    }
  }
  onAnchorHoveredChanged: updateCloseTimer()
  onPopupHoveredChanged: updateCloseTimer()
  Component.onCompleted: updateCloseTimer()

  Timer {
    id: closeTimer
    interval: 3000
    onTriggered: if (!popup.anchorHovered && !popup.popupHovered) popup.dismiss()
  }

  Timer {
    id: fadeOutTimer
    interval: 180
    onTriggered: {
      popup.open = false;
      popup.fadingOut = false;
    }
  }

  Rectangle {
    id: popupSurface
    anchors.fill: parent
    radius: 16
    color: popup.shell.surface
    border.color: popup.shell.outlineVariant
    border.width: 1
    opacity: popup.fadingOut ? 0 : 1

    Behavior on opacity {
      NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    HoverHandler {
      id: popupHover
    }

    TapHandler {
      onTapped: popup.dismiss()
    }

    Column {
      id: content
      anchors.fill: parent
      anchors.margins: 12
      spacing: 10

      RowLayout {
        width: parent.width
        spacing: 10

        ColumnLayout {
          spacing: 2
          Layout.fillWidth: true

          Text {
            text: "Battery"
            color: popup.shell.surfaceContent
            font.family: popup.shell.fontFamily
            font.pointSize: popup.shell.fontPointSize + 3
            font.weight: Font.DemiBold
          }

          Text {
            text: popup.stateLabel()
            color: popup.shell.surfaceVariantContent
            font.family: popup.shell.fontFamily
            font.pointSize: popup.shell.fontPointSize - 1
          }
        }

        Text {
          text: popup.shell.batteryPercentage(popup.battery) + "% " + popup.shell.batteryIcon(popup.battery)
          color: popup.shell.batteryPercentage(popup.battery) <= 15 && UPower.onBattery
            ? popup.shell.overdrive
            : popup.shell.primaryContent
          font.family: popup.shell.fontFamily
          font.pointSize: popup.shell.fontPointSize + 5
          font.weight: Font.DemiBold
          Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }
      }

      Rectangle {
        width: parent.width
        height: 8
        radius: 4
        color: popup.shell.surfaceContainerHighest

        Rectangle {
          width: parent.width * Math.max(0, Math.min(1, popup.battery.percentage))
          height: parent.height
          radius: parent.radius
          color: popup.shell.batteryPercentage(popup.battery) <= 15 && UPower.onBattery
            ? popup.shell.overdrive
            : popup.shell.primaryContent

          Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
          }
        }
      }

      Rectangle {
        width: parent.width
        implicitHeight: stats.implicitHeight + 16
        radius: 11
        color: popup.shell.surfaceContainerHigh

        Column {
          id: stats
          anchors.fill: parent
          anchors.margins: 8
          spacing: 7

          Repeater {
            model: [
              { label: "Estimate", value: popup.estimateLabel() },
              { label: UPower.onBattery ? "Power draw" : "Power flow", value: popup.powerLabel() },
              { label: "Energy", value: popup.energyLabel() },
              { label: "Health", value: popup.healthLabel() },
              { label: "Cycles", value: popup.shell.batteryStats.cycle_count || "Not available" },
              { label: "Voltage", value: popup.voltageLabel() },
              { label: "Battery", value: popup.modelLabel() }
            ]

            RowLayout {
              required property var modelData
              width: stats.width

              Text {
                text: modelData.label
                color: popup.shell.surfaceVariantContent
                font.family: popup.shell.fontFamily
                font.pointSize: popup.shell.fontPointSize - 1
                Layout.fillWidth: true
              }

              Text {
                text: modelData.value
                color: popup.shell.surfaceContent
                font.family: popup.shell.fontFamily
                font.pointSize: popup.shell.fontPointSize - 1
                font.weight: Font.Medium
              }
            }
          }
        }
      }
    }
  }
}
