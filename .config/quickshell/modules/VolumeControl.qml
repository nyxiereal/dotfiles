import QtQuick
import QtQuick.Layouts

Rectangle {
  id: control

  required property var shell
  required property var node
  required property string title

  implicitHeight: content.implicitHeight + 20
  radius: 12
  color: shell.surfaceContainerHigh
  border.color: shell.outlineVariant
  border.width: 1

  ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Text {
        text: control.title
        color: control.shell.surfaceContent
        font.family: control.shell.fontFamily
        font.pointSize: control.shell.fontPointSize
        font.weight: Font.DemiBold
        Layout.fillWidth: true
        elide: Text.ElideRight
      }

      Text {
        text: control.node && control.node.audio ? Math.round(control.node.audio.volume * 100) + "%" : "--%"
        color: control.node && control.node.audio && control.node.audio.volume > 1 ? control.shell.overdrive : control.shell.surfaceVariantContent
        font.family: control.shell.fontFamily
        font.pointSize: control.shell.fontPointSize
      }

      Rectangle {
        implicitWidth: 58
        implicitHeight: 26
        radius: 10
        color: control.node && control.node.audio && control.node.audio.muted ? control.shell.errorContainer : control.shell.secondaryContainer

        Text {
          anchors.centerIn: parent
          text: control.node && control.node.audio && control.node.audio.muted ? "Muted" : "Mute"
          color: control.node && control.node.audio && control.node.audio.muted ? control.shell.errorContent : control.shell.secondaryContent
          font.family: control.shell.fontFamily
          font.pointSize: control.shell.fontPointSize - 1
          font.weight: Font.Medium
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: if (control.node && control.node.ready && control.node.audio) control.node.audio.muted = !control.node.audio.muted
        }
      }
    }

    Text {
      text: control.shell.nodeLabel(control.node)
      color: control.shell.surfaceVariantContent
      font.family: control.shell.fontFamily
      font.pointSize: control.shell.fontPointSize - 1
      elide: Text.ElideRight
      Layout.fillWidth: true
    }

    AudioSlider {
      Layout.fillWidth: true
      implicitHeight: 28
      shell: control.shell
      node: control.node
    }
  }
}
