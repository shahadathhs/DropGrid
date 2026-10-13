'use client'

import { useState } from 'react'
import { ChevronRight, Settings as SettingsIcon, Sparkles, Trophy, UserRound, Volume2, VolumeX } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Avatar, Btn, Eyebrow, Screen, Stat, TopBar } from '@/components/ui'

export function HubScreen() {
  const { go, signedIn, username, stats } = useApp()

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

      <Stat label="Best score" value={stats.bestScore.toLocaleString()} />

      <Btn icon={ChevronRight} iconEnd={ChevronRight} className="hub-play" onClick={() => go('game')}>
        Continue run
      </Btn>

      <div className="hub-links">
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

export function ProfileScreen() {
  const { go, reset, signedIn, username, stats, update } = useApp()
  const [confirmingDelete, setConfirmingDelete] = useState(false)

  // Sign-out and account deletion both drop the session; local stats stay on the device.
  const leaveAccount = () => {
    update({ signedIn: false, username: '', email: '' })
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
        <p>{signedIn ? 'Synced account' : 'Guest, saved on this device'}</p>
      </div>

      <div className="stat-row profile-stats">
        <Stat label="Best score" value={stats.bestScore.toLocaleString()} />
        <Stat label="Total lines" value={stats.totalLines.toLocaleString()} />
        <Stat label="Games" value={stats.gamesPlayed.toLocaleString()} />
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
  const { sound, update } = useApp()

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
      </div>
    </Screen>
  )
}
