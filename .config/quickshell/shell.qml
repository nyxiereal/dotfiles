import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import QtQuick
import "modules"

ShellRoot {
  id: root

  property color surface: "#111318"
  property color surfaceContainer: "#1d2024"
  property color surfaceContainerHigh: "#272a2f"
  property color surfaceContainerHighest: "#32353a"
  property color surfaceContent: "#e3e2e9"
  property color surfaceVariantContent: "#c7c5d0"
  property color primaryContainer: "#4f378b"
  property color primaryContent: "#eaddff"
  property color secondaryContainer: "#4a4458"
  property color secondaryContent: "#e8def8"
  property color tertiaryContainer: "#633b48"
  property color tertiaryContent: "#ffd8e4"
  property color errorContainer: "#8c1d18"
  property color errorContent: "#f9dedc"
  property color overdrive: "#ff5449"
  property color outlineVariant: "#44474e"

  property string fontFamily: "FiraCode Nerd Font"
  property int fontPointSize: 9
  property string waybarDir: Quickshell.env("HOME") + "/.config/waybar"
  property string driveText: ""
  property string driveTooltip: ""
  property string driveClass: "hidden"
  property bool easyEffectsRunning: false
  property string audioRouteScript: Quickshell.env("HOME") + "/.config/quickshell/audio-route"
  property string preferredMonitorAudioOutput: "Q27G42XE"
  property bool preferredMonitorAudioOutputSelected: false
  property var monitorAudioRoutes: []
  property string monitorAudioRouteError: ""
  property alias clockService: clock

  function parseDriveOutput(output) {
    var raw = output.trim();
    if (raw.length === 0) {
      driveText = "";
      driveTooltip = "";
      driveClass = "hidden";
      return;
    }

    try {
      var data = JSON.parse(raw);
      driveText = data.text || "";
      driveTooltip = data.tooltip || "";
      driveClass = data.class || "hidden";
    } catch (error) {
      driveText = "";
      driveTooltip = raw;
      driveClass = "hidden";
    }
  }

  function parseMonitorAudioRoutes(output) {
    var raw = output.trim();
    if (raw.length === 0) {
      monitorAudioRoutes = [];
      monitorAudioRouteError = "No monitor outputs found";
      return;
    }

    try {
      monitorAudioRoutes = JSON.parse(raw);
      monitorAudioRouteError = "";

      if (!preferredMonitorAudioOutputSelected) {
        for (var i = 0; i < monitorAudioRoutes.length; i++) {
          var route = monitorAudioRoutes[i];
          if (route.monitor === preferredMonitorAudioOutput) {
            preferredMonitorAudioOutputSelected = true;
            if (!route.currentDefault) {
              switchMonitorAudioRoute(route);
            }
            break;
          }
        }
      }
    } catch (error) {
      monitorAudioRoutes = [];
      monitorAudioRouteError = raw;
    }
  }

  function workspaceLabel(workspace) {
    if (workspace.name && workspace.name !== String(workspace.id)) {
      return workspace.name;
    }

    return String(workspace.id);
  }

  function windowTitleForMonitor(monitor) {
    var toplevel = Hyprland.activeToplevel;
    if (!toplevel || !toplevel.title) {
      return "";
    }

    if (monitor && toplevel.monitor && toplevel.monitor.name !== monitor.name) {
      return "";
    }

    return toplevel.title;
  }

  function bestPlayer() {
    var players = Mpris.players.values;
    if (!players || players.length === 0) {
      return null;
    }

    for (var i = 0; i < players.length; i++) {
      if (players[i].isPlaying) {
        return players[i];
      }
    }

    return players[0];
  }

  function mediaLabel(player) {
    if (!player || !player.trackTitle) {
      return "";
    }

    var artist = player.trackArtist || player.trackArtists || "";
    var track = artist.length > 0 ? artist + " - " + player.trackTitle : player.trackTitle;
    return "[" + (player.isPlaying ? "󰏤" : "󰐊") + "] " + track;
  }

  function volumeIcon(sink) {
    if (!sink || !sink.ready || !sink.audio || sink.audio.muted) {
      return "󰝟";
    }

    if (sink.audio.volume < 0.34) {
      return "󰕿";
    }

    if (sink.audio.volume < 0.67) {
      return "󰖀";
    }

    return "󰕾";
  }

  function volumeLabel(sink) {
    if (!sink || !sink.ready || !sink.audio) {
      return "--% 󰝟";
    }

    if (sink.audio.muted) {
      return "󰝟";
    }

    return Math.round(sink.audio.volume * 100) + "% " + volumeIcon(sink);
  }

  function microphoneLabel(source) {
    if (!source || !source.ready || !source.audio) {
      return "--% 󰍭";
    }

    if (source.audio.muted) {
      return "󰍭";
    }

    return Math.round(source.audio.volume * 100) + "% 󰍬";
  }

  function nodeLabel(node) {
    if (!node) {
      return "Unknown";
    }

    return node.description || node.nickname || node.name || "PipeWire node " + node.id;
  }

  function clampAudioVolume(value) {
    return Math.max(0, Math.min(1.5, value));
  }

  function setNodeVolume(node, volume) {
    if (!node || !node.ready || !node.audio) {
      return;
    }

    node.audio.volume = clampAudioVolume(volume);
  }

  function audioNodes(filter) {
    var nodes = Pipewire.nodes.values || [];
    var filtered = [];

    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node && node.audio && filter(node)) {
        filtered.push(node);
      }
    }

    return filtered;
  }

  function outputDevices() {
    return audioNodes(function(node) { return !node.isStream && node.isSink; });
  }

  function inputDevices() {
    return audioNodes(function(node) { return !node.isStream && !node.isSink; });
  }

  function audioStreams() {
    return audioNodes(function(node) { return node.isStream; });
  }

  function trackedAudioNodes() {
    var nodes = [];
    var allNodes = Pipewire.nodes.values || [];
    for (var i = 0; i < allNodes.length; i++) {
      if (allNodes[i] && allNodes[i].audio) {
        nodes.push(allNodes[i]);
      }
    }

    return nodes;
  }

  function setVolume(sink, delta) {
    if (!sink || !sink.ready || !sink.audio) {
      return;
    }

    sink.audio.volume = clampAudioVolume(sink.audio.volume + delta);
  }

  function switchMonitorAudioRoute(route) {
    if (!route || !route.card || !route.profile || !route.sink) {
      return;
    }

    Quickshell.execDetached(["sh", audioRouteScript, "switch", route.card, route.profile, route.sink]);
    monitorAudioRoutesRefreshAfterAction.restart();
  }

  function refreshMonitorAudioRoutes() {
    monitorAudioRoutesCheck.running = true;
  }

  function performDriveAction(action) {
    Quickshell.execDetached([waybarDir + "/drive-detect", action]);
    driveRefreshAfterAction.restart();
  }

  function toggleEasyEffects() {
    if (easyEffectsRunning) {
      Quickshell.execDetached(["sh", audioRouteScript, "stop-easyeffects"]);
    } else {
      Quickshell.execDetached(["easyeffects", "--service-mode"]);
    }
    easyEffectsRefreshAfterAction.restart();
  }

  function trayIconSource(icon) {
    if (!icon) {
      return "";
    }

    var path = Quickshell.iconPath(icon, true);
    return path.length > 0 ? path : icon;
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  PwObjectTracker {
    objects: root.trackedAudioNodes()
  }

  Process {
    id: driveCheck
    command: [root.waybarDir + "/drive-detect"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.parseDriveOutput(text)
    }
  }

  Process {
    id: easyEffectsCheck
    command: ["sh", "-c", "pgrep -x easyeffects >/dev/null && printf running || printf stopped"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.easyEffectsRunning = text.trim() === "running"
    }
  }

  Process {
    id: monitorAudioRoutesCheck
    command: ["sh", root.audioRouteScript, "list"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.parseMonitorAudioRoutes(text)
    }
  }

  Timer {
    interval: 10000
    running: true
    repeat: true
    onTriggered: driveCheck.running = true
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: easyEffectsCheck.running = true
  }

  Timer {
    interval: 10000
    running: true
    repeat: true
    onTriggered: monitorAudioRoutesCheck.running = true
  }

  Timer {
    id: driveRefreshAfterAction
    interval: 800
    onTriggered: driveCheck.running = true
  }

  Timer {
    id: easyEffectsRefreshAfterAction
    interval: 800
    onTriggered: easyEffectsCheck.running = true
  }

  Timer {
    id: monitorAudioRoutesRefreshAfterAction
    interval: 1000
    onTriggered: monitorAudioRoutesCheck.running = true
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      TopBar {
        required property var modelData
        shell: root
        screenData: modelData
      }
    }
  }
}
