import QtQuick
import QtQuick.Layouts

Rectangle {
  id: row

  required property var shell
  required property var node

  implicitHeight: 62
  radius: 9
  color: shell.surfaceContainerHigh

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 6

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Text {
        text: row.shell.nodeLabel(row.node)
        color: row.shell.surfaceContent
        font.family: row.shell.fontFamily
        font.pointSize: row.shell.fontPointSize - 1
        elide: Text.ElideRight
        Layout.fillWidth: true
      }

      Text {
        text: row.node.audio ? Math.round(row.node.audio.volume * 100) + "%" : "--%"
        color: row.node.audio && row.node.audio.volume > 1 ? row.shell.overdrive : row.shell.surfaceVariantContent
        font.family: row.shell.fontFamily
        font.pointSize: row.shell.fontPointSize - 1
      }
    }

    AudioSlider {
      Layout.fillWidth: true
      implicitHeight: 18
      shell: row.shell
      node: row.node
      fillColor: row.shell.secondaryContainer
      thumbColor: row.shell.secondaryContent
      trackHeight: 6
      thumbSize: 12
      rightClickMutes: true
    }
  }
}
