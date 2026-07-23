import QtQuick
import QtQuick.Layouts

Rectangle {
  id: module

  required property var shell
  required property var barWindow

  visible: shell.driveText.length > 0
  implicitWidth: visible ? driveText.implicitWidth + barWindow.pillPadding * 2 : 0
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.driveClass === "drive-detected" ? shell.tertiaryContainer : shell.surfaceContainerHigh
  Layout.preferredWidth: implicitWidth

  Text {
    id: driveText
    anchors.centerIn: parent
    text: shell.driveText
    color: shell.driveClass === "drive-detected" ? shell.tertiaryContent : shell.surfaceContent
    font.family: shell.fontFamily
    font.pointSize: shell.fontPointSize
    font.weight: Font.Medium
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      shell.performDriveAction(mouse.button === Qt.RightButton ? "unmount" : "sync");
    }
  }
}
