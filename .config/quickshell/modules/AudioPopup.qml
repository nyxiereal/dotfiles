import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: popup

  required property var shell
  required property var barWindow
  required property var sink
  required property var mic
  required property bool compact
  required property real screenHeight
  required property int barHeight
  required property real popupX

  property bool open: false
  property bool pinned: false
  property bool focusGrabReady: false
  property var peakHistory: [0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06]

  visible: open
  color: "transparent"
  implicitWidth: compact ? 350 : 400
  implicitHeight: Math.min(content.implicitHeight + 24, screenHeight - barHeight - 32)

  anchor.window: barWindow
  anchor.rect.x: popupX
  anchor.rect.y: barHeight + 8

  onVisibleChanged: {
    if (visible) {
      shell.refreshMonitorAudioRoutes();
      focusGrabReady = false;
      focusGrabDelay.restart();
    } else {
      focusGrabReady = false;
      if (open) open = false;
    }
  }

  PwNodePeakMonitor {
    id: outputPeakMonitor
    node: popup.sink
    enabled: popup.visible
  }

  Timer {
    interval: 60
    running: popup.visible
    repeat: true
    onTriggered: {
      var history = popup.peakHistory.slice(1);
      history.push(Math.max(0.06, Math.min(1, Math.sqrt(outputPeakMonitor.peak))));
      popup.peakHistory = history;
    }
  }

  HyprlandFocusGrab {
    active: popup.focusGrabReady && popup.visible && !popup.pinned
    windows: [popup, popup.barWindow]
    onCleared: if (!popup.pinned) popup.open = false
  }

  Timer {
    id: focusGrabDelay
    interval: 120
    onTriggered: popup.focusGrabReady = popup.visible
  }

  Rectangle {
    anchors.fill: parent
    radius: 18
    color: popup.shell.surface
    border.color: popup.shell.outlineVariant
    border.width: 1
    clip: true

    Flickable {
      anchors.fill: parent
      anchors.margins: 12
      contentWidth: width
      contentHeight: content.implicitHeight
      clip: true

      Column {
        id: content
        width: parent.width
        spacing: 10

        RowLayout {
          width: parent.width
          spacing: 10

          ColumnLayout {
            spacing: 2
            Layout.fillWidth: true

            Text {
              text: "Audio"
              color: popup.shell.surfaceContent
              font.family: popup.shell.fontFamily
              font.pointSize: popup.shell.fontPointSize + 4
              font.weight: Font.DemiBold
            }

            Text {
              text: Pipewire.ready ? "Sound and device routing" : "Connecting to PipeWire..."
              color: popup.shell.surfaceVariantContent
              font.family: popup.shell.fontFamily
              font.pointSize: popup.shell.fontPointSize - 1
              elide: Text.ElideRight
              Layout.fillWidth: true
            }
          }

          Item {
            id: visualizer
            implicitWidth: 106
            implicitHeight: 30
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            Row {
              anchors.fill: parent
              spacing: 2

              Repeater {
                model: popup.peakHistory

                Item {
                  required property real modelData
                  width: 4
                  height: visualizer.height

                  Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: Math.max(2, parent.height * modelData)
                    radius: 2
                    color: popup.shell.primaryContent
                    opacity: 0.78

                    Behavior on height {
                      NumberAnimation { duration: 70; easing.type: Easing.OutCubic }
                    }
                  }
                }
              }
            }
          }

          Rectangle {
            implicitWidth: popup.pinned ? 62 : 44
            implicitHeight: 28
            radius: 9
            color: popup.pinned ? popup.shell.primaryContainer : (pinMouse.containsMouse ? popup.shell.surfaceContainerHighest : popup.shell.surfaceContainerHigh)
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            Text {
              anchors.centerIn: parent
              text: popup.pinned ? "Pinned" : "Pin"
              color: popup.pinned ? popup.shell.primaryContent : popup.shell.surfaceVariantContent
              font.family: popup.shell.fontFamily
              font.pointSize: popup.shell.fontPointSize - 1
              font.weight: Font.Medium
            }

            MouseArea {
              id: pinMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: popup.pinned = !popup.pinned
            }
          }
        }

        VolumeControl {
          width: parent.width
          shell: popup.shell
          node: popup.sink
          title: "Output"
        }

        VolumeControl {
          width: parent.width
          shell: popup.shell
          node: popup.mic
          title: "Input"
        }

        EasyEffectsModule {
          width: parent.width
          shell: popup.shell
        }

        MonitorOutputsModule {
          width: parent.width
          shell: popup.shell
        }

        Text {
          text: "Output devices"
          color: popup.shell.surfaceVariantContent
          font.family: popup.shell.fontFamily
          font.pointSize: popup.shell.fontPointSize
          font.weight: Font.DemiBold
        }

        Repeater {
          model: popup.shell.outputDevices()

          AudioDeviceRow {
            required property var modelData
            width: content.width
            shell: popup.shell
            node: modelData
            input: false
          }
        }

        Text {
          text: "Input devices"
          color: popup.shell.surfaceVariantContent
          font.family: popup.shell.fontFamily
          font.pointSize: popup.shell.fontPointSize
          font.weight: Font.DemiBold
        }

        Repeater {
          model: popup.shell.inputDevices()

          AudioDeviceRow {
            required property var modelData
            width: content.width
            shell: popup.shell
            node: modelData
            input: true
          }
        }

        Text {
          visible: popup.shell.audioStreams().length > 0
          text: "Streams"
          color: popup.shell.surfaceVariantContent
          font.family: popup.shell.fontFamily
          font.pointSize: popup.shell.fontPointSize
          font.weight: Font.DemiBold
        }

        Repeater {
          model: popup.shell.audioStreams()

          AudioStreamRow {
            required property var modelData
            width: content.width
            shell: popup.shell
            node: modelData
          }
        }
      }
    }
  }
}
