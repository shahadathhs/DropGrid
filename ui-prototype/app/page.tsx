'use client'

import { AppProvider, useApp } from '@/lib/app'
import type { ScreenId } from '@/lib/app'
import { MenuScreen } from '@/components/screens/menu'
import { AccountScreen } from '@/components/screens/account'
import { HubScreen, ProfileScreen, SettingsScreen } from '@/components/screens/hub'
import { LeaderboardScreen } from '@/components/screens/leaderboard'
import { GameOverScreen, GameScreen, PausedScreen } from '@/components/screens/play'

const SCREENS: Record<ScreenId, () => React.JSX.Element> = {
  menu: MenuScreen,
  account: AccountScreen,
  hub: HubScreen,
  leaderboard: () => <LeaderboardScreen />,
  'leaderboard-offline': () => <LeaderboardScreen offline />,
  profile: ProfileScreen,
  settings: SettingsScreen,
  game: GameScreen,
  paused: PausedScreen,
  'game-over': GameOverScreen,
}

const SWITCHER: Array<[ScreenId, string]> = [
  ['menu', 'Menu'],
  ['account', 'Account'],
  ['hub', 'Home'],
  ['leaderboard', 'Leaderboard'],
  ['leaderboard-offline', 'Leaderboard error'],
  ['profile', 'Profile'],
  ['settings', 'Settings'],
  ['game', 'Game'],
  ['paused', 'Paused'],
  ['game-over', 'Game over'],
]

function Phone() {
  const { screen } = useApp()
  const Active = SCREENS[screen]
  return (
    <div className="phone-frame" key={screen}>
      <Active />
    </div>
  )
}

function Switcher() {
  const { screen, reset } = useApp()
  return (
    <div className="screen-switcher">
      <span>Screens</span>
      {SWITCHER.map(([id, label]) => (
        <button key={id} className={screen === id ? 'active' : ''} onClick={() => reset(id)}>
          {label}
        </button>
      ))}
    </div>
  )
}

export default function Page() {
  return (
    <AppProvider>
      <main className="prototype-shell">
        <Phone />
        <Switcher />
      </main>
    </AppProvider>
  )
}
