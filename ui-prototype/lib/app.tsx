'use client'

import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'

export type ScreenId =
  | 'menu'
  | 'account'
  | 'email'
  | 'otp'
  | 'profile-setup'
  | 'hub'
  | 'levels'
  | 'profile'
  | 'settings'
  | 'game'
  | 'paused'
  | 'game-over'

export interface AppState {
  guest: boolean
  username: string
  email: string
  sound: boolean
  haptics: boolean
  best: number
  lastRun: { score: number; lines: number; level: number; newBest: boolean }
}

interface AppContextValue extends AppState {
  screen: ScreenId
  go: (screen: ScreenId) => void
  back: () => void
  reset: (screen: ScreenId) => void
  update: (patch: Partial<AppState>) => void
}

const AppContext = createContext<AppContextValue | null>(null)

const INITIAL: AppState = {
  guest: true,
  username: 'Jordan',
  email: '',
  sound: true,
  haptics: true,
  best: 18460,
  lastRun: { score: 0, lines: 0, level: 1, newBest: false },
}

export function AppProvider({ children }: { children: ReactNode }) {
  const [stack, setStack] = useState<ScreenId[]>(['menu'])
  const [state, setState] = useState<AppState>(INITIAL)

  const go = useCallback((screen: ScreenId) => setStack((s) => [...s, screen]), [])
  const back = useCallback(() => setStack((s) => (s.length > 1 ? s.slice(0, -1) : s)), [])
  const reset = useCallback((screen: ScreenId) => setStack([screen]), [])
  const update = useCallback((patch: Partial<AppState>) => setState((s) => ({ ...s, ...patch })), [])

  const value = useMemo<AppContextValue>(
    () => ({ ...state, screen: stack[stack.length - 1], go, back, reset, update }),
    [state, stack, go, back, reset, update],
  )

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}

export function useApp(): AppContextValue {
  const ctx = useContext(AppContext)
  if (!ctx) throw new Error('useApp must be used inside <AppProvider>')
  return ctx
}
