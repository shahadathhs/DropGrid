'use client'

import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'

export type ScreenId =
  | 'menu'
  | 'account'
  | 'hub'
  | 'leaderboard'
  | 'leaderboard-offline'
  | 'profile'
  | 'settings'
  | 'game'
  | 'paused'
  | 'game-over'

export interface SyncedStats {
  bestScore: number
  totalLines: number
  gamesPlayed: number
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
  sound: boolean
  stats: SyncedStats
  lastRun: LastRun
}

interface AppContextValue extends AppState {
  screen: ScreenId
  go: (screen: ScreenId) => void
  back: () => void
  reset: (screen: ScreenId) => void
  update: (patch: Partial<AppState>) => void
  finishRun: (run: { score: number; lines: number; level: number }) => void
}

const AppContext = createContext<AppContextValue | null>(null)

const INITIAL: AppState = {
  signedIn: false,
  username: 'Jordan',
  email: '',
  sound: true,
  stats: { bestScore: 18460, totalLines: 384, gamesPlayed: 62 },
  lastRun: { score: 0, lines: 0, level: 1, newBest: false },
}

export function AppProvider({ children }: { children: ReactNode }) {
  const [stack, setStack] = useState<ScreenId[]>(['menu'])
  const [state, setState] = useState<AppState>(INITIAL)

  const go = useCallback((screen: ScreenId) => setStack((s) => [...s, screen]), [])
  const back = useCallback(() => setStack((s) => (s.length > 1 ? s.slice(0, -1) : s)), [])
  const reset = useCallback((screen: ScreenId) => setStack([screen]), [])
  const update = useCallback((patch: Partial<AppState>) => setState((s) => ({ ...s, ...patch })), [])

  const finishRun = useCallback(
    (run: { score: number; lines: number; level: number }) =>
      setState((s) => {
        const newBest = run.score > s.stats.bestScore
        return {
          ...s,
          stats: {
            bestScore: Math.max(s.stats.bestScore, run.score),
            totalLines: s.stats.totalLines + run.lines,
            gamesPlayed: s.stats.gamesPlayed + 1,
          },
          lastRun: { ...run, newBest },
        }
      }),
    [],
  )

  const value = useMemo<AppContextValue>(
    () => ({ ...state, screen: stack[stack.length - 1], go, back, reset, update, finishRun }),
    [state, stack, go, back, reset, update, finishRun],
  )

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext)
  if (!ctx) throw new Error('useApp must be used inside <AppProvider>')
  return ctx
}
