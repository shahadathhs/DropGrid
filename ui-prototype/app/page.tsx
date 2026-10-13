'use client'

import { AppProvider, useApp } from '@/lib/app'
import type { ScreenId } from '@/lib/app'
import { MenuScreen } from '@/components/screens/menu'
import { AccountScreen, EmailScreen, OtpScreen, ProfileSetupScreen, SignInScreen } from '@/components/screens/auth'
import { HubScreen, LevelsScreen, ProfileScreen, SettingsScreen } from '@/components/screens/hub'
import { LeaderboardScreen } from '@/components/screens/leaderboard'
import { GameOverScreen, GameScreen, PausedScreen } from '@/components/screens/play'

const SCREENS: Record<ScreenId, () => React.JSX.Element> = {
  menu: MenuScreen,
  account: AccountScreen,
  'sign-in': SignInScreen,
  email: EmailScreen,
  otp: OtpScreen,
  'profile-setup': ProfileSetupScreen,
  hub: HubScreen,
  levels: LevelsScreen,
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
  ['sign-in', 'Sign in'],
  ['email', 'Email'],
  ['otp', 'Password'],
  ['profile-setup', 'Username'],
  ['hub', 'Home'],
  ['levels', 'Levels'],
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
