import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: bar

  required property var shell
  required property var screenData

  property var hyprMonitor: Hyprland.monitorFor(screenData)
  property var player: shell.bestPlayer()
  property var sink: Pipewire.defaultAudioSink
  property var mic: Pipewire.defaultAudioSource
  property string mediaText: shell.mediaLabel(player)
  property string activeWindowTitle: shell.windowTitleForMonitor(hyprMonitor)
  property bool tiny: screenData.width < 1150
  property bool compact: screenData.width < 1650
  property int barHeight: Math.max(40, Math.min(48, Math.round(screenData.height * 0.026)))
  property int outerMargin: compact ? 6 : 8
  property int pillHeight: Math.max(30, barHeight - 10)
  property int pillPadding: compact ? 10 : 12
  property int pillRadius: 12
  property int gap: compact ? 6 : 8

  function audioPopupX() {
    var anchorX = bar.itemPosition(audioModule).x + audioModule.width - audioPopup.width;
    return Math.max(bar.outerMargin, Math.min(bar.width - audioPopup.width - bar.outerMargin, anchorX));
  }

  screen: screenData
  implicitHeight: barHeight
  color: "transparent"
  exclusiveZone: barHeight

  anchors {
    top: true
    left: true
    right: true
  }

  Rectangle {
    anchors.fill: parent
    color: bar.shell.surface

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: 1
      color: bar.shell.outlineVariant
      opacity: 0.45
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: bar.outerMargin
      anchors.rightMargin: bar.outerMargin
      anchors.topMargin: Math.round((bar.barHeight - bar.pillHeight) / 2)
      anchors.bottomMargin: Math.round((bar.barHeight - bar.pillHeight) / 2)
      spacing: bar.gap

      RowLayout {
        spacing: bar.gap
        Layout.alignment: Qt.AlignVCenter

        WorkspacesModule {
          shell: bar.shell
          barWindow: bar
          Layout.alignment: Qt.AlignVCenter
        }

        ActiveWindowModule {
          shell: bar.shell
          barWindow: bar
          Layout.alignment: Qt.AlignVCenter
        }
      }

      Item { Layout.fillWidth: true }

      RowLayout {
        spacing: bar.gap
        Layout.alignment: Qt.AlignVCenter

        DriveModule {
          shell: bar.shell
          barWindow: bar
          Layout.alignment: Qt.AlignVCenter
        }

        MediaModule {
          shell: bar.shell
          barWindow: bar
          Layout.alignment: Qt.AlignVCenter
        }

        AudioModule {
          id: audioModule
          shell: bar.shell
          barWindow: bar
          Layout.alignment: Qt.AlignVCenter
          onTogglePopup: audioPopup.open = !audioPopup.open
        }

        ClockModule {
          shell: bar.shell
          barWindow: bar
          Layout.alignment: Qt.AlignVCenter
        }

        TrayModule {
          shell: bar.shell
          barWindow: bar
          Layout.alignment: Qt.AlignVCenter
        }
      }
    }
  }

  AudioPopup {
    id: audioPopup
    shell: bar.shell
    barWindow: bar
    sink: bar.sink
    mic: bar.mic
    compact: bar.compact
    screenHeight: bar.screenData.height
    barHeight: bar.barHeight
    popupX: bar.audioPopupX()
  }
}
