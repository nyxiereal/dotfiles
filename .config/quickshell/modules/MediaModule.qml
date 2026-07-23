import QtQuick
import QtQuick.Layouts

Rectangle {
  id: module

  required property var shell
  required property var barWindow

  visible: !barWindow.tiny && barWindow.mediaText.length > 0
  implicitWidth: visible ? Math.min(mediaText.implicitWidth + barWindow.pillPadding * 2, barWindow.compact ? 220 : 360) : 0
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.secondaryContainer
  clip: true
  Layout.maximumWidth: barWindow.compact ? 220 : 360
  Layout.preferredWidth: implicitWidth

  Text {
    id: mediaText
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: barWindow.pillPadding
    anchors.rightMargin: barWindow.pillPadding
    text: barWindow.mediaText
    color: shell.secondaryContent
    elide: Text.ElideRight
    font.family: shell.fontFamily
    font.pointSize: shell.fontPointSize
    font.weight: Font.Medium
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: if (barWindow.player && barWindow.player.canTogglePlaying) barWindow.player.togglePlaying()
    onWheel: function(wheel) {
      if (!barWindow.player) return;

      if (wheel.angleDelta.y > 0 && barWindow.player.canGoNext) {
        barWindow.player.next();
      } else if (wheel.angleDelta.y < 0 && barWindow.player.canGoPrevious) {
        barWindow.player.previous();
      }
    }
  }
}
