'use client'

import { ChevronRight, LockKeyhole, Settings as SettingsIcon, ShieldCheck, Sparkles, Trophy, UserRound, Volume2, VolumeX, Vibrate } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Avatar, Btn, Eyebrow, Progress, Screen, Stat, TopBar } from '@/components/ui'

const LEVELS = [
  { n: 1, name: 'First drop', state: 'done', reward: '100 XP' },
  { n: 2, name: 'Find the rhythm', state: 'done', reward: '150 XP' },
  { n: 3, name: 'Stack smart', state: 'current', reward: '250 XP' },
  { n: 4, name: 'Clean sweep', state: 'locked', reward: '400 XP' },
  { n: 5, name: 'High voltage', state: 'locked', reward: '600 XP' },
]

export function HubScreen() {
  const { go, guest, username, best } = useApp()

  return (
    <Screen className="screen-hub">
      <header className="hub-header">
        <div>
          <Eyebrow>{guest ? 'Welcome, guest' : 'Welcome back'}</Eyebrow>
          <h2>
            Ready to drop,
            <br />
            <em>{guest ? 'Player.' : `${username}.`}</em>
          </h2>
        </div>
        <button className="avatar-btn" aria-label="Open profile" onClick={() => go('profile')}>
          <Avatar label={guest ? 'G' : username.slice(0, 2).toUpperCase()} />
        </button>
      </header>

      {guest && (
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
          <strong>12</strong>
          <p>Rising stacker</p>
        </div>
        <div className="level-ring" aria-label="Level 12">
          12
        </div>
      </div>
      <Progress value="68%" label="680 / 1,000 XP" />

      <div className="stat-row">
        <Stat label="Rating" value="1,248" />
        <Stat label="Streak" value="07" />
        <Stat label="Best" value={best >= 1000 ? `${(best / 1000).toFixed(1)}k` : String(best)} />
      </div>

      <Btn icon={ChevronRight} iconEnd={ChevronRight} className="hub-play" onClick={() => go('game')}>
        Continue run
      </Btn>

      <div className="hub-links">
        <button onClick={() => go('levels')}>
          <Trophy size={18} />
          <span>
            Levels
            <small>3 / 12 unlocked</small>
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
  const { reset } = useApp()

  return (
    <Screen className="screen-levels">
      <TopBar title="Level path" />
      <div className="levels-heading">
        <Eyebrow>Season 01</Eyebrow>
        <h2>
          Build your
          <br />
          <em>momentum.</em>
        </h2>
        <p>Clear challenges to climb the path.</p>
      </div>
      <div className="level-tree">
        {LEVELS.map((level) => (
          <button
            key={level.n}
            className={`level-node ${level.state}`}
            disabled={level.state === 'locked'}
            onClick={() => level.state === 'current' && reset('game')}
          >
            <span className="node-icon">
              {level.state === 'locked' ? <LockKeyhole size={16} /> : level.state === 'done' ? <ShieldCheck size={16} /> : level.n}
            </span>
            <span className="node-copy">
              <b>
                Level {String(level.n).padStart(2, '0')} · {level.name}
              </b>
              <small>
                {level.state === 'locked' ? 'Complete the previous level' : level.state === 'done' ? 'Completed' : 'Ready to play'} ·{' '}
                {level.reward}
              </small>
            </span>
            <ChevronRight size={16} />
          </button>
        ))}
      </div>
    </Screen>
  )
}

export function ProfileScreen() {
  const { go, reset, guest, username, best, update } = useApp()

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
        <Avatar label={guest ? 'G' : username.slice(0, 2).toUpperCase()} />
        <h2>{guest ? 'Guest Player' : username}</h2>
        <p>
          {guest ? 'Guest account' : 'Member'} <span>·</span> <b>Rank 08</b>
        </p>
      </div>
      <div className="rank-card">
        <div className="rank-badge">
          <Trophy size={18} />
        </div>
        <div>
          <Eyebrow>Current rating</Eyebrow>
          <strong>1,248</strong>
          <small>Top 18% of players</small>
        </div>
        <span className="rating-up">+84</span>
      </div>
      <Progress value="68%" label="Level 12 · 680 / 1,000 XP" />
      <div className="stat-grid">
        <Stat label="Best score" value={best.toLocaleString()} />
        <Stat label="Lines cleared" value="384" />
        <Stat label="Longest streak" value="14" />
        <Stat label="Games played" value="62" />
      </div>
      {guest ? (
        <Btn variant="secondary" onClick={() => go('account')}>
          Create a profile
        </Btn>
      ) : (
        <Btn
          variant="text"
          className="sign-out"
          onClick={() => {
            update({ guest: true })
            reset('menu')
          }}
        >
          Sign out
        </Btn>
      )}
    </Screen>
  )
}

export function SettingsScreen() {
  const { sound, haptics, update } = useApp()

  return (
    <Screen className="screen-settings">
      <TopBar title="Settings" />
      <div className="settings-list">
        <button className="setting-row" onClick={() => update({ sound: !sound })}>
          <span className="setting-icon">{sound ? <Volume2 size={17} /> : <VolumeX size={17} />}</span>
          <span>
            <strong>Sound effects</strong>
            <small>Movement, clears, and feedback</small>
          </span>
          <span className={`toggle ${sound ? 'on' : ''}`}>
            <i />
          </span>
        </button>
        <button className="setting-row" onClick={() => update({ haptics: !haptics })}>
          <span className="setting-icon">
            <Vibrate size={17} />
          </span>
          <span>
            <strong>Haptics</strong>
            <small>Touch feedback while playing</small>
          </span>
          <span className={`toggle ${haptics ? 'on' : ''}`}>
            <i />
          </span>
        </button>
      </div>
      <div className="settings-note">
        <span>Prototype mode</span>
        <p>Account and gameplay data shown here is illustrative for the visual prototype.</p>
      </div>
    </Screen>
  )
}
