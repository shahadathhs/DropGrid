'use client'

import { Play, CircleUserRound, Trophy, UserRound } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Brand, Btn, Eyebrow, Screen } from '@/components/ui'

export function MenuScreen() {
  const { go, reset, signedIn, stats } = useApp()

  return (
    <Screen className="screen-menu">
      <Brand />
      <div className="menu-hero">
        <div className="hero-grid" aria-hidden="true">
          {Array.from({ length: 8 }).map((_, i) => (
            <span key={i} />
          ))}
        </div>
        <Eyebrow>A focused arcade puzzle</Eyebrow>
        <h1>
          Find your
          <br />
          <em>flow.</em>
        </h1>
        <p className="hero-copy">
          Stack smart. Clear lines.
          <br />
          Beat your best.
        </p>
      </div>
      <div className="menu-actions">
        <Btn icon={Play} onClick={() => reset('game')}>
          Play
        </Btn>
        {signedIn ? (
          <Btn variant="secondary" icon={UserRound} onClick={() => go('profile')}>
            Profile
          </Btn>
        ) : (
          <Btn variant="secondary" icon={CircleUserRound} onClick={() => go('account')}>
            Sign in
          </Btn>
        )}
        <Btn variant="secondary" icon={Trophy} onClick={() => go('leaderboard')}>
          Leaderboard
        </Btn>
      </div>
      <div className="best-note">
        <span>Personal best</span>
        <strong>{stats.bestScore.toLocaleString()}</strong>
      </div>
      <p className="version">DropGrid · v1.0.0</p>
    </Screen>
  )
}
