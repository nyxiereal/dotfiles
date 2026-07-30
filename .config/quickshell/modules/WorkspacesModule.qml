import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Rectangle {
  id: module

  required property var shell
  required property var barWindow

  property string mangoSignature: Quickshell.env("MANGO_INSTANCE_SIGNATURE") || ""
  property bool mango: mangoSignature.length > 0
  property var mangoWorkspaces: []

  function updateMangoWorkspaces(output) {
    try {
      var groups = JSON.parse(output).all_tags || [];
      var screenName = barWindow.screenData ? barWindow.screenData.name : "";
      var workspaces = [];

      for (var i = 0; i < groups.length; i++) {
        if (groups[i].monitor !== screenName) continue;
        var tags = groups[i].tags || [];
        for (var j = 0; j < tags.length; j++) {
          var tag = tags[j];
          if (tag.client_count > 0 || tag.is_active || tag.is_urgent) {
            workspaces.push({
              id: tag.index,
              name: String(tag.index),
              focused: tag.is_active,
              urgent: tag.is_urgent
            });
          }
        }
        break;
      }

      mangoWorkspaces = workspaces;
    } catch (error) {
      console.warn("Unable to parse Mango workspace state:", error);
    }
  }

  function activateWorkspace(workspace) {
    if (mango) {
      Quickshell.execDetached(["mmsg", "dispatch", "view," + workspace.id + ",0"]);
    } else {
      workspace.activate();
    }
  }

  implicitWidth: workspacesRow.implicitWidth + barWindow.pillPadding * 2
  implicitHeight: barWindow.pillHeight
  radius: barWindow.pillRadius
  color: shell.surfaceContainerHigh

  Row {
    id: workspacesRow
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: module.mango ? module.mangoWorkspaces : Hyprland.workspaces

      Rectangle {
        id: workspaceButton
        required property var modelData

        property bool onThisMonitor: module.mango || !modelData.monitor || modelData.monitor.name === barWindow.screenData.name

        visible: onThisMonitor
        width: visible ? Math.max(18, workspaceText.implicitWidth + 8) : 0
        height: barWindow.pillHeight - 6
        radius: 7
        color: modelData.urgent ? shell.errorContainer : (modelData.focused ? shell.primaryContainer : (workspaceMouse.containsMouse ? shell.surfaceContainerHighest : "transparent"))

        Behavior on color {
          ColorAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        Text {
          id: workspaceText
          anchors.centerIn: parent
          text: shell.workspaceLabel(modelData)
          color: modelData.urgent ? shell.errorContent : (modelData.focused ? shell.primaryContent : shell.surfaceVariantContent)
          font.family: shell.fontFamily
          font.pointSize: shell.fontPointSize
          font.weight: Font.Medium
        }

        MouseArea {
          id: workspaceMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: module.activateWorkspace(modelData)
        }
      }
    }
  }

  Process {
    command: ["mmsg", "watch", "all-tags"]
    running: module.mango

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => module.updateMangoWorkspaces(data)
    }
  }
}
