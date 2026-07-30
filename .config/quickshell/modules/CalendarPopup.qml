import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: popup

  required property var shell
  required property var barWindow
  required property bool triggerHovered
  required property real screenWidth
  required property int barHeight
  required property real popupX

  property bool open: false
  property bool contentHovered: false
  readonly property date today: shell.clockService.date
  readonly property int currentYear: today.getFullYear()
  readonly property int currentMonth: today.getMonth()
  readonly property int currentDay: today.getDate()
  readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  readonly property var weekdayNames: ["M", "T", "W", "T", "F", "S", "S"]

  function firstWeekday(month) {
    return (new Date(currentYear, month, 1).getDay() + 6) % 7;
  }

  function daysInMonth(month) {
    return new Date(currentYear, month + 1, 0).getDate();
  }

  function dayForCell(month, cell) {
    var day = cell - firstWeekday(month) + 1;
    return day > 0 && day <= daysInMonth(month) ? day : 0;
  }

  function updateOpenState() {
    if (triggerHovered || contentHovered) {
      closeDelay.stop();
      open = true;
    } else if (open) {
      closeDelay.restart();
    }
  }

  visible: open
  color: "transparent"
  implicitWidth: Math.min(820, screenWidth - 32)
  implicitHeight: 570

  anchor.window: barWindow
  anchor.rect.x: popupX
  anchor.rect.y: barHeight + 8

  onTriggerHoveredChanged: updateOpenState()
  onContentHoveredChanged: updateOpenState()

  Timer {
    id: closeDelay
    interval: 180
    onTriggered: if (!popup.triggerHovered && !popup.contentHovered) popup.open = false
  }

  Rectangle {
    anchors.fill: parent
    radius: 18
    color: popup.shell.surface
    border.color: popup.shell.outlineVariant
    border.width: 1

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
      onContainsMouseChanged: popup.contentHovered = containsMouse
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 10

      RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
          text: popup.currentYear
          color: popup.shell.surfaceContent
          font.family: popup.shell.fontFamily
          font.pointSize: popup.shell.fontPointSize + 5
          font.weight: Font.DemiBold
        }

        Item { Layout.fillWidth: true }

        Text {
          text: Qt.formatDate(popup.today, "dddd, MMMM d")
          color: popup.shell.primaryContent
          font.family: popup.shell.fontFamily
          font.pointSize: popup.shell.fontPointSize
          font.weight: Font.Medium
        }
      }

      GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 4
        columnSpacing: 8
        rowSpacing: 8

        Repeater {
          model: 12

          Rectangle {
            id: monthCard

            required property int index
            readonly property bool isCurrentMonth: index === popup.currentMonth

            Layout.fillWidth: true
            Layout.fillHeight: true
            color: isCurrentMonth ? popup.shell.surfaceContainerHigh : popup.shell.surfaceContainer
            radius: 12
            border.color: isCurrentMonth ? popup.shell.primaryContainer : popup.shell.outlineVariant
            border.width: isCurrentMonth ? 2 : 1

            Column {
              anchors.fill: parent
              anchors.margins: 7
              spacing: 3

              Text {
                width: parent.width
                text: popup.monthNames[monthCard.index]
                color: monthCard.isCurrentMonth ? popup.shell.primaryContent : popup.shell.surfaceContent
                font.family: popup.shell.fontFamily
                font.pointSize: popup.shell.fontPointSize
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
              }

              Grid {
                width: parent.width
                columns: 7

                Repeater {
                  model: popup.weekdayNames

                  Text {
                    required property string modelData
                    width: parent.width / 7
                    height: 16
                    text: modelData
                    color: popup.shell.surfaceVariantContent
                    font.family: popup.shell.fontFamily
                    font.pixelSize: 9
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                  }
                }
              }

              Grid {
                width: parent.width
                columns: 7

                Repeater {
                  model: 42

                  Item {
                    required property int index
                    readonly property int day: popup.dayForCell(monthCard.index, index)
                    readonly property bool isToday: monthCard.isCurrentMonth && day === popup.currentDay
                    width: parent.width / 7
                    height: 17

                    Rectangle {
                      anchors.centerIn: parent
                      width: 17
                      height: 17
                      radius: 6
                      visible: parent.isToday
                      color: popup.shell.primaryContainer
                    }

                    Text {
                      anchors.centerIn: parent
                      text: parent.day > 0 ? parent.day : ""
                      color: parent.isToday ? popup.shell.primaryContent : popup.shell.surfaceContent
                      font.family: popup.shell.fontFamily
                      font.pixelSize: 9
                      font.weight: parent.isToday ? Font.Bold : Font.Normal
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
