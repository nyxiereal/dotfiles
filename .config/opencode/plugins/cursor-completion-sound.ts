import { spawn } from "node:child_process"
import { existsSync } from "node:fs"
import type { Plugin } from "@opencode-ai/plugin"

const cursorSoundDir = "/usr/share/cursor/resources/app/out/vs/platform/accessibilitySignal/browser/media"
const completionSounds = ["done1.mp3"].map((file) => `${cursorSoundDir}/${file}`)

const player = existsSync("/usr/bin/pw-play") ? "/usr/bin/pw-play" : "pw-play"
const minIntervalMs = 500
const completionFallbackMs = 1500
const stateKey = Symbol.for("opencode.cursorCompletionSound")

type State = {
  activeSessions: Set<string>
  childSessions: Set<string>
  completionTimers: Map<string, ReturnType<typeof setTimeout>>
  lastPlayedAt: Map<string, number>
  mainSessions: Set<string>
  messagesWithActionParts: Set<string>
  sessionLookups: Map<string, Promise<boolean>>
}

function state() {
  const global = globalThis as typeof globalThis & { [stateKey]?: State }

  return (global[stateKey] ??= {
    activeSessions: new Set<string>(),
    childSessions: new Set<string>(),
    completionTimers: new Map<string, ReturnType<typeof setTimeout>>(),
    lastPlayedAt: new Map<string, number>(),
    mainSessions: new Set<string>(),
    messagesWithActionParts: new Set<string>(),
    sessionLookups: new Map<string, Promise<boolean>>(),
  })
}

function isActionPart(type: string) {
  return type === "tool" || type === "subtask" || type === "agent"
}

function playCursorCompletionSound() {
  const sounds = completionSounds.filter((sound) => existsSync(sound))
  if (sounds.length === 0) return

  const sound = sounds[Math.floor(Math.random() * sounds.length)]
  const child = spawn(player, [sound], {
    detached: true,
    stdio: "ignore",
  })

  child.on("error", () => {})
  child.unref()
}

const plugin = (async ({ client }) => {
  function clearCompletionTimer(sessionID: string) {
    const timer = state().completionTimers.get(sessionID)
    if (!timer) return

    clearTimeout(timer)
    state().completionTimers.delete(sessionID)
  }

  function markActive(sessionID: string) {
    clearCompletionTimer(sessionID)
    state().activeSessions.add(sessionID)
  }

  function playOnce(sessionID: string) {
    const now = Date.now()
    const currentState = state()
    if (now - (currentState.lastPlayedAt.get(sessionID) ?? 0) < minIntervalMs) return

    clearCompletionTimer(sessionID)
    currentState.activeSessions.delete(sessionID)
    currentState.lastPlayedAt.set(sessionID, now)
    playCursorCompletionSound()
  }

  function scheduleCompletionFallback(sessionID: string) {
    const timer = setTimeout(() => {
      if (state().activeSessions.has(sessionID)) playOnce(sessionID)
    }, completionFallbackMs)

    clearCompletionTimer(sessionID)
    state().completionTimers.set(sessionID, timer)
    timer.unref?.()
  }

  function rememberSession(info: { id: string; parentID?: string }) {
    const currentState = state()
    currentState.sessionLookups.delete(info.id)

    if (info.parentID) {
      currentState.childSessions.add(info.id)
      currentState.mainSessions.delete(info.id)
      currentState.activeSessions.delete(info.id)
      clearCompletionTimer(info.id)
      return
    }

    currentState.mainSessions.add(info.id)
    currentState.childSessions.delete(info.id)
  }

  function forgetSession(info: { id: string }) {
    const currentState = state()
    clearCompletionTimer(info.id)
    currentState.activeSessions.delete(info.id)
    currentState.childSessions.delete(info.id)
    currentState.mainSessions.delete(info.id)
    currentState.lastPlayedAt.delete(info.id)
    currentState.sessionLookups.delete(info.id)
  }

  async function isMainSession(sessionID: string) {
    const currentState = state()
    if (currentState.childSessions.has(sessionID)) return false
    if (currentState.mainSessions.has(sessionID)) return true

    const existingLookup = currentState.sessionLookups.get(sessionID)
    if (existingLookup) return existingLookup

    const lookup = client.session
      .get({ path: { id: sessionID } })
      .then((result) => {
        if (result.data) {
          rememberSession(result.data)
          return !result.data.parentID
        }

        return true
      })
      .catch(() => true)
      .finally(() => state().sessionLookups.delete(sessionID))

    currentState.sessionLookups.set(sessionID, lookup)
    return lookup
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.created" || event.type === "session.updated") {
        rememberSession(event.properties.info)
        return
      }

      if (event.type === "session.deleted") {
        forgetSession(event.properties.info)
        return
      }

      if (event.type === "message.removed") {
        state().messagesWithActionParts.delete(event.properties.messageID)
        return
      }

      if (event.type === "session.status") {
        const sessionID = event.properties.sessionID
        if (!(await isMainSession(sessionID))) return

        if (event.properties.status.type !== "idle") {
          markActive(sessionID)
          return
        }

        if (state().activeSessions.has(sessionID)) playOnce(sessionID)
        return
      }

      if (event.type === "session.idle") {
        const sessionID = event.properties.sessionID
        if (!(await isMainSession(sessionID))) return

        if (state().activeSessions.has(sessionID)) playOnce(sessionID)
        return
      }

      if (event.type === "message.part.updated") {
        const part = event.properties.part
        const sessionID = part.sessionID
        if (!(await isMainSession(sessionID))) return

        if (isActionPart(part.type)) state().messagesWithActionParts.add(part.messageID)
        markActive(sessionID)
        return
      }

      if (event.type === "message.updated") {
        const info = event.properties.info
        if (info.role !== "assistant" || info.summary || info.mode === "title") return
        if (!(await isMainSession(info.sessionID))) return

        markActive(info.sessionID)
        if (info.time.completed && !info.error && !state().messagesWithActionParts.has(info.id)) {
          scheduleCompletionFallback(info.sessionID)
        }
      }
    },
  }
}) satisfies Plugin

export { plugin as server }
export default plugin
