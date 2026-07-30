import Quickshell.Services.UPower
import QtQuick

Rectangle {
  id: module

  required property var shell
  required property var barWindow
  signal toggleBatteryPopup()

  property bool batteryVisible: shell.hasLaptopBattery
  property bool brightnessVisible: shell.hasLaptopBattery && shell.brightnessPercentage >= 0
  property alias batteryHovered: batteryMouse.containsMouse

  visible: batteryVisible || brightnessVisible
  implicitWidth: visible ? statusRow.implicitWidth : 0
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.surfaceContainerHigh
  clip: true

  Row {
    id: statusRow
    anchors.centerIn: parent
    height: parent.height

    Rectangle {
      id: batteryPill
      visible: module.batteryVisible
      width: visible ? batteryText.implicitWidth + barWindow.pillPadding * 2 : 0
      height: parent.height
      color: batteryMouse.containsMouse ? shell.surfaceContainerHighest : "transparent"

      Text {
        id: batteryText
        anchors.centerIn: parent
        text: shell.batteryLabel(shell.battery)
        color: shell.batteryPercentage(shell.battery) <= 15 && UPower.onBattery
          ? shell.overdrive
          : shell.surfaceContent
        font.family: shell.fontFamily
        font.pointSize: shell.fontPointSize
        font.weight: Font.Medium
      }

      MouseArea {
        id: batteryMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: module.toggleBatteryPopup()
      }
    }

    Rectangle {
      visible: module.batteryVisible && module.brightnessVisible
      width: visible ? 1 : 0
      height: parent.height - 12
      anchors.verticalCenter: parent.verticalCenter
      color: shell.outlineVariant
    }

    Rectangle {
      visible: module.brightnessVisible
      width: visible ? brightnessText.implicitWidth + barWindow.pillPadding * 2 : 0
      height: parent.height
      color: brightnessMouse.containsMouse ? shell.surfaceContainerHighest : "transparent"

      Text {
        id: brightnessText
        anchors.centerIn: parent
        text: shell.brightnessPercentage + "% 󰃠"
        color: shell.surfaceContent
        font.family: shell.fontFamily
        font.pointSize: shell.fontPointSize
        font.weight: Font.Medium
      }

      MouseArea {
        id: brightnessMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onWheel: function(wheel) {
          shell.adjustBrightness(wheel.angleDelta.y > 0 ? 1 : -1);
        }
      }
    }
  }
}
