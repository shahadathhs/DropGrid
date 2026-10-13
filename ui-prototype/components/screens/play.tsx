'use client'

import { ChevronDown, ChevronLeft, ChevronRight, Pause, Play, RotateCw } from 'lucide-react'
import { LINES_PER_LEVEL, fallIntervalSeconds, levelForLines, useApp } from '@/lib/app'
import { Btn, Eyebrow, IconBtn, Screen, Stat } from '@/components/ui'
import { Board, NextPiece } from '@/components/game'

// Live values for the run in progress come from app state. The board art is static,
// so the run only changes through the app state (it starts at zero).
export function GameScreen() {
  const { go, stats, run } = useApp()
  const level = levelForLines(run.lines)
  const linesIntoLevel = run.lines % LINES_PER_LEVEL
  const linesToNext = LINES_PER_LEVEL - linesIntoLevel

  return (
    <Screen className="screen-game">
      <header className="game-header">
        <IconBtn label="Pause game" icon={Pause} onClick={() => go('paused')} />
        <div className="live-score">
          <span>Score</span>
          <strong>{run.score.toLocaleString()}</strong>
        </div>
        <div className="mini-best">
          <span>Best</span>
          <strong>{Math.max(stats.bestScore, run.score).toLocaleString()}</strong>
        </div>
      </header>
      <div className="game-meta">
        <span className="level-pill">Level {String(level).padStart(2, '0')}</span>
        <span className="next-label">
          Next <NextPiece />
        </span>
      </div>
      <Board />
      <div className="progress-line">
        <span className="track">
          <i style={{ width: `${(linesIntoLevel / LINES_PER_LEVEL) * 100}%` }} />
        </span>
        <span>
          {linesToNext} lines to level {String(level + 1).padStart(2, '0')}
        </span>
      </div>
      <div className="stat-row">
        <Stat label="Lines" value={String(run.lines)} />
        <Stat label="Level" value={String(level)} />
        <Stat label="Drop" value={`${fallIntervalSeconds(level).toFixed(2)}s`} />
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
  const { back, stats, run, reset, finishRun } = useApp()
  const level = levelForLines(run.lines)

  const endRun = () => {
    finishRun()
    reset('game-over')
  }

  return (
    <Screen className="screen-game paused">
      <header className="game-header">
        <IconBtn label="Resume game" icon={Play} onClick={back} />
        <div className="live-score">
          <span>Score</span>
          <strong>{run.score.toLocaleString()}</strong>
        </div>
        <div className="mini-best">
          <span>Best</span>
          <strong>{Math.max(stats.bestScore, run.score).toLocaleString()}</strong>
        </div>
      </header>
      <div className="game-meta">
        <span className="level-pill">Level {String(level).padStart(2, '0')}</span>
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
  const { lastRun, stats, reset, go, startRun } = useApp()

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
            Best <b>{stats.bestScore.toLocaleString()}</b>
          </span>
        </div>
      </div>
      <div className="stack">
        <Btn
          icon={Play}
          onClick={() => {
            startRun()
            reset('game')
          }}
        >
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
