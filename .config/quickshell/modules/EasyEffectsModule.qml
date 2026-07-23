import QtQuick
import QtQuick.Layouts

Rectangle {
  id: module

  required property var shell

  implicitHeight: effectsRow.implicitHeight + 20
  radius: 12
  color: shell.surfaceContainerHigh
  border.color: shell.outlineVariant
  border.width: 1

  RowLayout {
    id: effectsRow
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    ColumnLayout {
      spacing: 2
      Layout.fillWidth: true

      Text {
        text: "EasyEffects"
        color: module.shell.surfaceContent
        font.family: module.shell.fontFamily
        font.pointSize: module.shell.fontPointSize
        font.weight: Font.DemiBold
      }

      Text {
        text: module.shell.easyEffectsRunning ? "Processing output" : "Effects disabled"
        color: module.shell.surfaceVariantContent
        font.family: module.shell.fontFamily
        font.pointSize: module.shell.fontPointSize - 1
      }
    }

    Rectangle {
      implicitWidth: 68
      implicitHeight: 30
      Layout.preferredWidth: 68
      Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
      radius: 9
      color: module.shell.easyEffectsRunning ? module.shell.secondaryContainer : module.shell.primaryContainer

      Text {
        anchors.centerIn: parent
        text: module.shell.easyEffectsRunning ? "Stop" : "Start"
        color: module.shell.easyEffectsRunning ? module.shell.secondaryContent : module.shell.primaryContent
        font.family: module.shell.fontFamily
        font.pointSize: module.shell.fontPointSize
        font.weight: Font.DemiBold
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: module.shell.toggleEasyEffects()
      }
    }
  }
}
