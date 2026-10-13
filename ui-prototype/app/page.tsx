'use client'

import { AppProvider, useApp } from '@/lib/app'
import type { ScreenId } from '@/lib/app'
import { MenuScreen } from '@/components/screens/menu'
import { AccountScreen, EmailScreen, OtpScreen, ProfileSetupScreen } from '@/components/screens/auth'
import { HubScreen, LevelsScreen, ProfileScreen, SettingsScreen } from '@/components/screens/hub'
import { GameOverScreen, GameScreen, PausedScreen } from '@/components/screens/play'

const SCREENS: Record<ScreenId, () => React.JSX.Element> = {
  menu: MenuScreen,
  account: AccountScreen,
  email: EmailScreen,
  otp: OtpScreen,
  'profile-setup': ProfileSetupScreen,
  hub: HubScreen,
  levels: LevelsScreen,
  profile: ProfileScreen,
  settings: SettingsScreen,
  game: GameScreen,
  paused: PausedScreen,
  'game-over': GameOverScreen,
}

const SWITCHER: Array<[ScreenId, string]> = [
  ['menu', 'Menu'],
  ['account', 'Sign in'],
  ['email', 'Email'],
  ['otp', 'Code'],
  ['profile-setup', 'Setup'],
  ['hub', 'Home'],
  ['levels', 'Levels'],
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
