import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: module

  required property var shell
  required property var barWindow

  visible: !barWindow.tiny && SystemTray.items.values.length > 0
  implicitWidth: visible ? trayRow.implicitWidth + barWindow.pillPadding * 2 : 0
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.surfaceContainerHigh
  Layout.preferredWidth: implicitWidth

  Row {
    id: trayRow
    anchors.centerIn: parent
    spacing: 6

    Repeater {
      model: SystemTray.items

      Item {
        id: trayIconBox
        required property var modelData

        width: barWindow.pillHeight - 8
        height: barWindow.pillHeight - 8
        opacity: modelData.status === Status.Passive ? 0.55 : 1

        Image {
          anchors.fill: parent
          source: shell.trayIconSource(modelData.icon)
          fillMode: Image.PreserveAspectFit
          smooth: true
          asynchronous: true
        }

        Rectangle {
          anchors.fill: parent
          radius: 3
          color: "transparent"
          border.color: modelData.status === Status.NeedsAttention ? shell.errorContainer : "transparent"
          border.width: 1
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton && modelData.hasMenu) {
              var pos = barWindow.itemPosition(trayIconBox);
              modelData.display(barWindow, pos.x, pos.y + trayIconBox.height);
            } else if (mouse.button === Qt.MiddleButton) {
              modelData.secondaryActivate();
            } else {
              modelData.activate();
            }
          }
          onWheel: function(wheel) {
            modelData.scroll(wheel.angleDelta.y, false);
          }
        }
      }
    }
  }
}
