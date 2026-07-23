import QtQuick

Item {
  id: slider

  required property var shell
  required property var node
  property color fillColor: shell.primaryContainer
  property color thumbColor: shell.primaryContent
  property int trackHeight: 8
  property int thumbSize: 16
  property bool rightClickMutes: false

  property real level: node && node.audio ? Math.min(node.audio.volume / 1.5, 1) : 0
  property bool boosted: node && node.audio && node.audio.volume > 1

  implicitHeight: Math.max(thumbSize, trackHeight + 4)

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    height: slider.trackHeight
    radius: height / 2
    color: slider.shell.surfaceContainerHighest
  }

  Rectangle {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width * Math.min(slider.level, 2 / 3)
    height: slider.trackHeight
    radius: height / 2
    color: slider.node && slider.node.audio && slider.node.audio.muted ? slider.shell.surfaceVariantContent : slider.fillColor
  }

  Rectangle {
    x: parent.width * 2 / 3
    anchors.verticalCenter: parent.verticalCenter
    width: slider.boosted ? parent.width * (slider.level - 2 / 3) : 0
    height: slider.trackHeight
    radius: height / 2
    color: slider.shell.overdrive
  }

  Rectangle {
    x: parent.width * 2 / 3 - width / 2
    anchors.verticalCenter: parent.verticalCenter
    width: 2
    height: slider.trackHeight + 4
    radius: 1
    color: slider.shell.surfaceVariantContent
    opacity: 0.55
  }

  Rectangle {
    width: slider.thumbSize
    height: slider.thumbSize
    radius: width / 2
    x: Math.max(0, Math.min(parent.width - width, parent.width * slider.level - width / 2))
    anchors.verticalCenter: parent.verticalCenter
    color: slider.boosted ? slider.shell.overdrive : slider.thumbColor
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: slider.rightClickMutes ? Qt.LeftButton | Qt.RightButton : Qt.LeftButton

    function updateVolume(mouseX) {
      slider.shell.setNodeVolume(slider.node, mouseX / Math.max(1, width) * 1.5);
    }

    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton && slider.rightClickMutes && slider.node && slider.node.ready && slider.node.audio) {
        slider.node.audio.muted = !slider.node.audio.muted;
      } else {
        updateVolume(mouse.x);
      }
    }
    onPositionChanged: function(mouse) { if (pressed) updateVolume(mouse.x); }
  }
}
