import Quickshell.Hyprland
import QtQuick

Rectangle {
  id: module

  required property var shell
  required property var barWindow

  implicitWidth: workspacesRow.implicitWidth + barWindow.pillPadding * 2
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.surfaceContainerHigh

  Row {
    id: workspacesRow
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: Hyprland.workspaces

      Rectangle {
        id: workspaceButton
        required property var modelData

        property bool onThisMonitor: !modelData.monitor || !barWindow.hyprMonitor || modelData.monitor.name === barWindow.hyprMonitor.name

        visible: onThisMonitor
        width: visible ? Math.max(18, workspaceText.implicitWidth + 8) : 0
        height: barWindow.pillHeight - 6
        radius: 7
        color: modelData.urgent ? shell.errorContainer : (modelData.focused ? shell.primaryContainer : (workspaceMouse.containsMouse ? shell.surfaceContainerHighest : "transparent"))

        Behavior on color {
          ColorAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        Text {
          id: workspaceText
          anchors.centerIn: parent
          text: shell.workspaceLabel(modelData)
          color: modelData.urgent ? shell.errorContent : (modelData.focused ? shell.primaryContent : shell.surfaceVariantContent)
          font.family: shell.fontFamily
          font.pointSize: shell.fontPointSize
          font.weight: Font.Medium
        }

        MouseArea {
          id: workspaceMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: modelData.activate()
        }
      }
    }
  }
}
