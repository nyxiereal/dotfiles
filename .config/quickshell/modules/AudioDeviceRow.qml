import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: row

  required property var shell
  required property var node
  required property bool input

  property bool selected: input ? node === Pipewire.defaultAudioSource : node === Pipewire.defaultAudioSink

  implicitHeight: 40
  radius: 9
  color: selected ? shell.primaryContainer : shell.surfaceContainerHigh

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 10
    anchors.rightMargin: 8
    spacing: 8

    Text {
      text: row.shell.nodeLabel(row.node)
      color: row.selected ? row.shell.primaryContent : row.shell.surfaceContent
      font.family: row.shell.fontFamily
      font.pointSize: row.shell.fontPointSize - 1
      elide: Text.ElideRight
      Layout.fillWidth: true
    }

    Text {
      text: row.selected ? "Default" : "Use"
      color: row.selected ? row.shell.primaryContent : row.shell.surfaceVariantContent
      font.family: row.shell.fontFamily
      font.pointSize: row.shell.fontPointSize - 1
      font.weight: Font.Medium
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (row.input) {
        Pipewire.preferredDefaultAudioSource = row.node;
      } else {
        Pipewire.preferredDefaultAudioSink = row.node;
      }
    }
  }
}
