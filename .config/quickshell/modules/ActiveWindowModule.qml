import QtQuick
import QtQuick.Layouts

Rectangle {
  id: module

  required property var shell
  required property var barWindow

  visible: !barWindow.tiny && barWindow.activeWindowTitle.length > 0
  implicitWidth: visible ? Math.min(windowText.implicitWidth + barWindow.pillPadding * 2, barWindow.compact ? 260 : 520) : 0
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.surfaceContainer
  clip: true
  Layout.maximumWidth: barWindow.compact ? 260 : 520
  Layout.preferredWidth: implicitWidth

  Text {
    id: windowText
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: barWindow.pillPadding
    anchors.rightMargin: barWindow.pillPadding
    text: barWindow.activeWindowTitle
    color: shell.surfaceContent
    elide: Text.ElideRight
    font.family: shell.fontFamily
    font.pointSize: shell.fontPointSize
    font.weight: Font.Medium
  }
}
