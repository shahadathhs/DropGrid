'use client'

import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'

export type ScreenId =
  | 'menu'
  | 'account'
  | 'sign-in'
  | 'email'
  | 'otp'
  | 'profile-setup'
  | 'hub'
  | 'levels'
  | 'leaderboard'
  | 'leaderboard-offline'
  | 'profile'
  | 'settings'
  | 'game'
  | 'paused'
  | 'game-over'

/**
 * Speed level rule, from docs/README_GAMEPLAY_FEATURES.md section 4:
 * "Increase level at a defined line-clear threshold, such as every 10 lines."
 */
export const LINES_PER_LEVEL = 10

/** Number of speed levels shown on the Level path screen. */
export const LEVEL_NODES = 10

/**
 * The one place that turns a line count into a level. Level 1 starts at 0 lines,
 * level 2 at 10 lines, level n at 10 * (n - 1) lines.
 */
export function levelForLines(totalLines: number): number {
  return Math.floor(totalLines / LINES_PER_LEVEL) + 1
}

/**
 * Seconds between automatic falls at a given level.
 * ASSUMPTION: the docs ask for a gradual speed-up with a minimum fall interval but give
 * no numbers. This prototype uses 1.00s at level 1, multiplied by 0.9 per level, and
 * never goes below 0.15s. Change the constants here if the game settles on other values.
 */
const BASE_FALL_SECONDS = 1
const FALL_DECAY = 0.9
const MIN_FALL_SECONDS = 0.15

export function fallIntervalSeconds(level: number): number {
  return Math.max(MIN_FALL_SECONDS, BASE_FALL_SECONDS * FALL_DECAY ** (level - 1))
}

export interface SyncedStats {
  bestScore: number
  totalLines: number
  gamesPlayed: number
}

/** The run in progress. Starts at zero for every new game. */
export interface RunState {
  score: number
  lines: number
}

export interface LastRun {
  score: number
  lines: number
  level: number
  newBest: boolean
}

export interface AppState {
  signedIn: boolean
  username: string
  email: string
  /** Prototype only: carries the password from the sign-up steps to the submit. Cleared after use. */
  password: string
  sound: boolean
  haptics: boolean
  stats: SyncedStats
  run: RunState
  lastRun: LastRun
}

interface AppContextValue extends AppState {
  screen: ScreenId
  go: (screen: ScreenId) => void
  back: () => void
  reset: (screen: ScreenId) => void
  update: (patch: Partial<AppState>) => void
  startRun: () => void
  finishRun: () => void
}

const AppContext = createContext<AppContextValue | null>(null)

// A fresh guest: nothing played yet, so every stat starts at zero.
const INITIAL: AppState = {
  signedIn: false,
  username: '',
  email: '',
  password: '',
  sound: true,
  haptics: true,
  stats: { bestScore: 0, totalLines: 0, gamesPlayed: 0 },
  run: { score: 0, lines: 0 },
  lastRun: { score: 0, lines: 0, level: 1, newBest: false },
}

export function AppProvider({ children }: { children: ReactNode }) {
  const [stack, setStack] = useState<ScreenId[]>(['menu'])
  const [state, setState] = useState<AppState>(INITIAL)

  const go = useCallback((screen: ScreenId) => setStack((s) => [...s, screen]), [])
  const back = useCallback(() => setStack((s) => (s.length > 1 ? s.slice(0, -1) : s)), [])
  const reset = useCallback((screen: ScreenId) => setStack([screen]), [])
  const update = useCallback((patch: Partial<AppState>) => setState((s) => ({ ...s, ...patch })), [])

  const startRun = useCallback(() => setState((s) => ({ ...s, run: { score: 0, lines: 0 } })), [])

  // Ends the current run. Lines add to the total, games played goes up by one, and the best
  // score becomes the max of the old best and this run's score (docs section 5: a single rule).
  const finishRun = useCallback(
    () =>
      setState((s) => {
        const { score, lines } = s.run
        return {
          ...s,
          stats: {
            bestScore: Math.max(s.stats.bestScore, score),
            totalLines: s.stats.totalLines + lines,
            gamesPlayed: s.stats.gamesPlayed + 1,
          },
          lastRun: {
            score,
            lines,
            level: levelForLines(lines),
            newBest: score > s.stats.bestScore,
          },
        }
      }),
    [],
  )

  const value = useMemo<AppContextValue>(
    () => ({
      ...state,
      screen: stack[stack.length - 1],
      go,
      back,
      reset,
      update,
      startRun,
      finishRun,
    }),
    [state, stack, go, back, reset, update, startRun, finishRun],
  )

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext)
  if (!ctx) throw new Error('useApp must be used inside <AppProvider>')
  return ctx
}
