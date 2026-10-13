'use client'

import { ChevronDown, ChevronLeft, ChevronRight, Pause, Play, RotateCw, Trophy } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Btn, Eyebrow, IconBtn, Screen, Stat } from '@/components/ui'
import { Board, NextPiece } from '@/components/game'

const RUN = { score: 12840, lines: 36, level: 4, linesToNext: 6 }

export function GameScreen() {
  const { go, best } = useApp()

  return (
    <Screen className="screen-game">
      <header className="game-header">
        <IconBtn label="Pause game" icon={Pause} onClick={() => go('paused')} />
        <div className="live-score">
          <span>Score</span>
          <strong>{RUN.score.toLocaleString()}</strong>
        </div>
        <div className="mini-best">
          <span>Best</span>
          <strong>{best.toLocaleString()}</strong>
        </div>
      </header>
      <div className="game-meta">
        <span className="level-pill">Level {String(RUN.level).padStart(2, '0')}</span>
        <span className="next-label">
          Next <NextPiece />
        </span>
      </div>
      <Board />
      <div className="progress-line">
        <span className="track">
          <i style={{ width: '40%' }} />
        </span>
        <span>{RUN.linesToNext} / 10 lines to level 05</span>
      </div>
      <div className="stat-row compact">
        <Stat label="Lines" value={String(RUN.lines)} />
        <Stat label="Level" value={String(RUN.level)} />
        <Stat label="Drop" value="1.2×" />
      </div>
      <div className="controls">
        <button aria-label="Move left">
          <ChevronLeft size={20} />
        </button>
        <button aria-label="Rotate">
          <RotateCw size={19} />
        </button>
        <button aria-label="Move right">
          <ChevronRight size={20} />
        </button>
        <button className="drop" aria-label="Soft drop">
          <ChevronDown size={20} />
        </button>
      </div>
    </Screen>
  )
}

export function PausedScreen() {
  const { back, go, best, reset, update } = useApp()

  const endRun = () => {
    update({ lastRun: { score: RUN.score, lines: RUN.lines, level: RUN.level, newBest: RUN.score > best } })
    reset('game-over')
  }

  return (
    <Screen className="screen-game paused">
      <header className="game-header">
        <IconBtn label="Resume game" icon={Play} onClick={back} />
        <div className="live-score">
          <span>Score</span>
          <strong>{RUN.score.toLocaleString()}</strong>
        </div>
        <div className="mini-best">
          <span>Best</span>
          <strong>{best.toLocaleString()}</strong>
        </div>
      </header>
      <div className="game-meta">
        <span className="level-pill">Level {String(RUN.level).padStart(2, '0')}</span>
      </div>
      <Board />
      <div className="pause-panel">
        <span className="panel-mark">
          <Pause size={18} />
        </span>
        <Eyebrow>Game paused</Eyebrow>
        <h2>Take a breath.</h2>
        <p>Your board is waiting for you.</p>
        <Btn icon={Play} onClick={back}>
          Resume
        </Btn>
        <Btn variant="text" onClick={endRun}>
          End run
        </Btn>
        <Btn variant="text" className="quiet" onClick={() => reset('hub')}>
          Quit to home
        </Btn>
      </div>
    </Screen>
  )
}

export function GameOverScreen() {
  const { lastRun, best, reset, go } = useApp()

  return (
    <Screen className="screen-modal">
      <div className="game-over-mark" aria-hidden="true">
        <span />
        <span />
        <span />
      </div>
      <Eyebrow>{lastRun.newBest ? 'New personal best' : 'Run over'}</Eyebrow>
      <h2>
        {lastRun.newBest ? (
          <>
            Beautiful.
            <br />
            <em>A new best.</em>
          </>
        ) : (
          <>
            Nice run.
            <br />
            <em>One more?</em>
          </>
        )}
      </h2>
      <div className="score-card">
        <span>Final score</span>
        <strong>{lastRun.score.toLocaleString()}</strong>
        <div>
          <span>
            Lines <b>{lastRun.lines}</b>
          </span>
          <span>
            Level <b>{lastRun.level}</b>
          </span>
          <span>
            Best <b>{best.toLocaleString()}</b>
          </span>
        </div>
      </div>
      <div className="stack">
        <Btn icon={Play} onClick={() => reset('game')}>
          Play again
        </Btn>
        <Btn variant="secondary" onClick={() => reset('hub')}>
          Home
        </Btn>
      </div>
      <Btn variant="text" className="quiet" onClick={() => go('levels')}>
        View level path
      </Btn>
    </Screen>
  )
}
