import QtQuick
import QtQuick.Layouts

Rectangle {
  id: module

  required property var shell

  implicitHeight: content.implicitHeight + 20
  radius: 12
  color: shell.surfaceContainerHigh
  border.color: shell.outlineVariant
  border.width: 1

  Column {
    id: content
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    RowLayout {
      width: parent.width
      spacing: 10

      Text {
        text: "Monitor outputs"
        color: module.shell.surfaceContent
        font.family: module.shell.fontFamily
        font.pointSize: module.shell.fontPointSize
        font.weight: Font.DemiBold
        Layout.fillWidth: true
      }

      Rectangle {
        implicitWidth: 62
        implicitHeight: 26
        radius: 10
        color: refreshMouse.containsMouse ? module.shell.surfaceContainerHighest : module.shell.surfaceContainer

        Text {
          anchors.centerIn: parent
          text: "Refresh"
          color: module.shell.surfaceVariantContent
          font.family: module.shell.fontFamily
          font.pointSize: module.shell.fontPointSize - 1
          font.weight: Font.Medium
        }

        MouseArea {
          id: refreshMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: module.shell.refreshMonitorAudioRoutes()
        }
      }
    }

    Text {
      width: parent.width
      text: "Switch the HDMI profile and move active audio."
      color: module.shell.surfaceVariantContent
      wrapMode: Text.WordWrap
      font.family: module.shell.fontFamily
      font.pointSize: module.shell.fontPointSize - 1
    }

    Text {
      visible: module.shell.monitorAudioRouteError.length > 0
      width: parent.width
      text: module.shell.monitorAudioRouteError
      color: module.shell.errorContent
      wrapMode: Text.WordWrap
      font.family: module.shell.fontFamily
      font.pointSize: module.shell.fontPointSize - 1
    }

    Repeater {
      model: module.shell.monitorAudioRoutes

      Rectangle {
        required property var modelData
        property bool selected: modelData.currentDefault || modelData.active

        width: content.width
        implicitHeight: 46
        radius: 9
        color: selected ? module.shell.primaryContainer : module.shell.surfaceContainerHighest

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8

          ColumnLayout {
            spacing: 1
            Layout.fillWidth: true

            Text {
              text: modelData.monitor.length > 0 ? modelData.monitor : modelData.portDescription
              color: selected ? module.shell.primaryContent : module.shell.surfaceContent
              font.family: module.shell.fontFamily
              font.pointSize: module.shell.fontPointSize
              font.weight: Font.DemiBold
              elide: Text.ElideRight
              Layout.fillWidth: true
            }

            Text {
              text: modelData.profileDescription
              color: selected ? module.shell.primaryContent : module.shell.surfaceVariantContent
              opacity: selected ? 0.78 : 1
              font.family: module.shell.fontFamily
              font.pointSize: module.shell.fontPointSize - 1
              elide: Text.ElideRight
              Layout.fillWidth: true
            }
          }

          Text {
            text: modelData.currentDefault ? "Default" : (modelData.active ? "Active" : "Use")
            color: selected ? module.shell.primaryContent : module.shell.surfaceVariantContent
            font.family: module.shell.fontFamily
            font.pointSize: module.shell.fontPointSize - 1
            font.weight: Font.Medium
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: module.shell.switchMonitorAudioRoute(modelData)
        }
      }
    }
  }
}
