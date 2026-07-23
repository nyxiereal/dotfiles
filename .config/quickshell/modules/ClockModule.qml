import QtQuick

Rectangle {
  id: module

  required property var shell
  required property var barWindow
  property bool expanded: false

  implicitWidth: clockText.implicitWidth + barWindow.pillPadding * 2
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.primaryContainer

  Text {
    id: clockText
    anchors.centerIn: parent
    text: module.expanded ? Qt.formatDateTime(shell.clockService.date, "dddd, MMMM d, yyyy (HH:mm)") : Qt.formatDateTime(shell.clockService.date, "HH:mm")
    color: shell.primaryContent
    font.family: shell.fontFamily
    font.pointSize: shell.fontPointSize
    font.weight: Font.Medium
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: module.expanded = !module.expanded
  }
}
