'use client'

import { useState } from 'react'
import {
  ChevronRight,
  LockKeyhole,
  Settings as SettingsIcon,
  ShieldCheck,
  Sparkles,
  Trophy,
  UserRound,
  Vibrate,
  Volume2,
  VolumeX,
} from 'lucide-react'
import { LEVEL_NODES, LINES_PER_LEVEL, fallIntervalSeconds, levelForLines, useApp } from '@/lib/app'
import { Avatar, Btn, Eyebrow, Screen, Stat, TopBar } from '@/components/ui'
import { leaderboardRank } from '@/components/screens/leaderboard'

export function HubScreen() {
  const { go, signedIn, username, stats } = useApp()
  const level = levelForLines(stats.totalLines)
  const linesToNext = LINES_PER_LEVEL - (stats.totalLines % LINES_PER_LEVEL)
  const unlocked = Math.min(level, LEVEL_NODES)

  return (
    <Screen className="screen-hub">
      <header className="hub-header">
        <div>
          <Eyebrow>{signedIn ? 'Welcome back' : 'Welcome, guest'}</Eyebrow>
          <h2>
            Ready to drop,
            <br />
            <em>{signedIn ? `${username}.` : 'Player.'}</em>
          </h2>
        </div>
        <button className="avatar-btn" aria-label="Open profile" onClick={() => go('profile')}>
          <Avatar label={signedIn ? username.slice(0, 2).toUpperCase() : 'G'} />
        </button>
      </header>

      {!signedIn && (
        <button className="guest-banner" onClick={() => go('account')}>
          <Sparkles size={16} />
          <span>
            <b>Playing as guest</b>
            <small>Create a profile to save progress.</small>
          </span>
          <ChevronRight size={16} />
        </button>
      )}

      <div className="level-card">
        <div>
          <Eyebrow>Player level</Eyebrow>
          <strong>{level}</strong>
          <p>{linesToNext} lines to next level</p>
        </div>
        <div className="level-ring" aria-label={`Level ${level}`}>
          {level}
        </div>
      </div>

      <div className="stat-row">
        <Stat label="Best score" value={stats.bestScore.toLocaleString()} />
        <Stat label="Total lines" value={stats.totalLines.toLocaleString()} />
        <Stat label="Games played" value={stats.gamesPlayed.toLocaleString()} />
      </div>

      <Btn icon={ChevronRight} iconEnd={ChevronRight} className="hub-play" onClick={() => go('game')}>
        Continue run
      </Btn>

      <div className="hub-links">
        <button onClick={() => go('levels')}>
          <Trophy size={18} />
          <span>
            Levels
            <small>
              {unlocked} / {LEVEL_NODES} unlocked
            </small>
          </span>
          <ChevronRight size={16} />
        </button>
        <button onClick={() => go('leaderboard')}>
          <Trophy size={18} />
          <span>
            Leaderboard
            <small>Top 50 by best score</small>
          </span>
          <ChevronRight size={16} />
        </button>
        <button onClick={() => go('profile')}>
          <UserRound size={18} />
          <span>
            Profile
            <small>View your stats</small>
          </span>
          <ChevronRight size={16} />
        </button>
      </div>
    </Screen>
  )
}

export function LevelsScreen() {
  const { reset, startRun, stats } = useApp()
  const current = levelForLines(stats.totalLines)

  return (
    <Screen className="screen-levels">
      <TopBar title="Level path" />
      <div className="levels-heading">
        <Eyebrow>Speed levels</Eyebrow>
        <h2>
          Every 10 lines
          <br />
          <em>is a level.</em>
        </h2>
        <p>Clear 10 lines to move up a speed level. Pieces fall faster on each level.</p>
      </div>
      <div className="level-tree">
        {Array.from({ length: LEVEL_NODES }, (_, i) => i + 1).map((n) => {
          // Rule from the docs: level n is completed once total lines reach 10 * n,
          // which is when level n + 1 starts. The next level to play is the current one.
          const completed = stats.totalLines >= LINES_PER_LEVEL * n
          const state = completed ? 'done' : n === current ? 'current' : 'locked'
          const detail =
            state === 'done'
              ? 'Completed'
              : state === 'current'
                ? `${LINES_PER_LEVEL * n - stats.totalLines} lines to go`
                : `Reach level ${n} at ${LINES_PER_LEVEL * (n - 1)} lines`

          return (
            <button
              key={n}
              className={`level-node ${state}`}
              disabled={state === 'locked'}
              onClick={() => {
                if (state !== 'current') return
                startRun()
                reset('game')
              }}
            >
              <span className="node-icon">
                {state === 'locked' ? <LockKeyhole size={16} /> : state === 'done' ? <ShieldCheck size={16} /> : n}
              </span>
              <span className="node-copy">
                <b>Level {String(n).padStart(2, '0')}</b>
                <small>
                  {detail} · drop {fallIntervalSeconds(n).toFixed(2)}s
                </small>
              </span>
              <ChevronRight size={16} />
            </button>
          )
        })}
      </div>
    </Screen>
  )
}

export function ProfileScreen() {
  const { go, reset, signedIn, username, stats, update } = useApp()
  const [confirmingDelete, setConfirmingDelete] = useState(false)
  const rank = signedIn ? leaderboardRank(stats.bestScore) : null

  // Sign-out and account deletion both drop the session; local stats stay on the device.
  const leaveAccount = () => {
    update({ signedIn: false, username: '', email: '', password: '' })
    reset('menu')
  }

  return (
    <Screen className="screen-profile">
      <TopBar
        title="Profile"
        action={
          <button className="icon-btn" aria-label="Settings" onClick={() => go('settings')}>
            <SettingsIcon size={17} />
          </button>
        }
      />
      <div className="profile-identity">
        <Avatar label={signedIn ? username.slice(0, 2).toUpperCase() : 'G'} />
        <h2>{signedIn ? username : 'Guest player'}</h2>
        <p>
          {signedIn ? 'Synced account' : 'Guest, saved on this device'}
          {signedIn && (
            <>
              {' '}
              <span>·</span>{' '}
              <b>{rank ? `Rank ${rank}` : 'Not in top 50'}</b>
            </>
          )}
        </p>
      </div>

      <div className="stat-grid">
        <Stat label="Best score" value={stats.bestScore.toLocaleString()} />
        <Stat label="Total lines" value={stats.totalLines.toLocaleString()} />
        <Stat label="Games played" value={stats.gamesPlayed.toLocaleString()} />
        <Stat label="Current level" value={String(levelForLines(stats.totalLines))} />
      </div>

      <div className="profile-actions stack">
        {!signedIn && (
          <Btn variant="secondary" onClick={() => go('account')}>
            Create a profile
          </Btn>
        )}

        {signedIn && !confirmingDelete && (
          <>
            <Btn variant="secondary" onClick={leaveAccount}>
              Sign out
            </Btn>
            <Btn variant="text" className="danger-text" onClick={() => setConfirmingDelete(true)}>
              Delete account
            </Btn>
          </>
        )}

        {signedIn && confirmingDelete && (
          <div className="confirm-panel" role="alertdialog" aria-labelledby="delete-title">
            <strong id="delete-title">Delete your account?</strong>
            <p>Your synced stats and leaderboard entry will be removed. This cannot be undone.</p>
            <Btn className="danger-btn" onClick={leaveAccount}>
              Delete account
            </Btn>
            <Btn variant="text" onClick={() => setConfirmingDelete(false)}>
              Cancel
            </Btn>
          </div>
        )}
      </div>
    </Screen>
  )
}

export function SettingsScreen() {
  const { sound, haptics, update } = useApp()

  return (
    <Screen className="screen-settings">
      <TopBar title="Settings" />
      <div className="settings-list">
        <button className="setting-row" onClick={() => update({ sound: !sound })} aria-pressed={sound}>
          <span className="setting-icon">{sound ? <Volume2 size={17} /> : <VolumeX size={17} />}</span>
          <span>
            <strong>Sound effects</strong>
            <small>Movement, clears, and feedback</small>
          </span>
          <span className={`toggle ${sound ? 'on' : ''}`}>
            <i />
          </span>
        </button>
        <button className="setting-row" onClick={() => update({ haptics: !haptics })} aria-pressed={haptics}>
          <span className="setting-icon">
            <Vibrate size={17} />
          </span>
          <span>
            <strong>Haptics</strong>
            <small>Touch feedback while playing. Android only.</small>
          </span>
          <span className={`toggle ${haptics ? 'on' : ''}`}>
            <i />
          </span>
        </button>
      </div>
    </Screen>
  )
}
