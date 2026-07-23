import QtQuick

Rectangle {
  id: module

  required property var shell
  required property var barWindow
  signal togglePopup()

  implicitWidth: audioPillRow.implicitWidth
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.surfaceContainerHigh
  clip: true

  Row {
    id: audioPillRow
    anchors.centerIn: parent
    height: parent.height

    Rectangle {
      width: volumeText.implicitWidth + barWindow.pillPadding * 2
      height: parent.height
      color: volumeMouse.containsMouse ? shell.surfaceContainerHighest : "transparent"

      Text {
        id: volumeText
        anchors.centerIn: parent
        text: shell.volumeLabel(barWindow.sink)
        color: barWindow.sink && barWindow.sink.audio && barWindow.sink.audio.muted ? shell.surfaceVariantContent : shell.surfaceContent
        font.family: shell.fontFamily
        font.pointSize: shell.fontPointSize
        font.weight: Font.Medium
      }

      MouseArea {
        id: volumeMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
          if (mouse.button === Qt.RightButton && barWindow.sink && barWindow.sink.ready && barWindow.sink.audio) {
            barWindow.sink.audio.muted = !barWindow.sink.audio.muted;
          } else {
            module.togglePopup();
          }
        }
        onWheel: function(wheel) {
          shell.setVolume(barWindow.sink, wheel.angleDelta.y > 0 ? 0.02 : -0.02);
        }
      }
    }

    Rectangle {
      visible: microphonePill.visible
      width: visible ? 1 : 0
      height: parent.height - 12
      anchors.verticalCenter: parent.verticalCenter
      color: shell.outlineVariant
    }

    Rectangle {
      id: microphonePill
      visible: barWindow.mic !== null
      width: visible ? microphoneText.implicitWidth + barWindow.pillPadding * 2 : 0
      height: parent.height
      color: microphoneMouse.containsMouse ? shell.surfaceContainerHighest : "transparent"

      Text {
        id: microphoneText
        anchors.centerIn: parent
        text: shell.microphoneLabel(barWindow.mic)
        color: barWindow.mic && barWindow.mic.ready && barWindow.mic.audio && barWindow.mic.audio.muted ? shell.surfaceVariantContent : shell.surfaceContent
        font.family: shell.fontFamily
        font.pointSize: shell.fontPointSize
        font.weight: Font.Medium
      }

      MouseArea {
        id: microphoneMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
          if (mouse.button === Qt.RightButton && barWindow.mic && barWindow.mic.ready && barWindow.mic.audio) {
            barWindow.mic.audio.muted = !barWindow.mic.audio.muted;
          } else {
            module.togglePopup();
          }
        }
        onWheel: function(wheel) {
          shell.setVolume(barWindow.mic, wheel.angleDelta.y > 0 ? 0.02 : -0.02);
        }
      }
    }
  }
}
