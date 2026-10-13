'use client'

import { useMemo } from 'react'
import { RotateCw, WifiOff } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Btn, Eyebrow, Screen, TopBar } from '@/components/ui'

// Illustrative top scores for the visual prototype. The live list comes from
// GET /v1/leaderboard (top 50 by best score).
const SAMPLE_NAMES = [
  'NovaStack', 'PixelDrift', 'GridRunner', 'QuietLine', 'TetraMind',
  'BlockBard', 'Lumen_07', 'VoltDrop', 'StackSmith', 'CobaltFox',
  'MintTempo', 'RookRise', 'Hexline', 'DeltaSweep', 'Kiln_22',
  'OrbitKid', 'SkyLedger', 'Ember9', 'ZenFold', 'Marlow',
  'AxisJay', 'Pinecone', 'Juno_X', 'LatchOn', 'FieldNote',
  'Brisk_11', 'TidalRow', 'SpindleK', 'Harbor_8', 'Quartz',
  'NeonSlate', 'Loom_3', 'RiftPiece', 'Sable', 'Crater_5',
  'GlassWren', 'Plume', 'Ioniq', 'Kestrel', 'Atlas_9',
  'Corvid', 'MoonRow', 'SolidAce', 'Drift_42', 'Oakline',
  'WispDrop', 'Tessel', 'Hush_77', 'Vantage', 'Pixie_K',
]

interface Row {
  name: string
  score: number
  me?: boolean
}

const SAMPLE: Row[] = SAMPLE_NAMES.map((name, i) => ({
  name,
  score: Math.round(52000 * Math.pow(0.975, i)),
}))

/**
 * Rank of a best score on the top-50 list, or null when it is not in the top 50.
 * A tie ranks below the equal scores already on the list, matching the sort above.
 */
export function leaderboardRank(bestScore: number): number | null {
  const rank = SAMPLE.filter((row) => row.score >= bestScore).length + 1
  return rank <= 50 ? rank : null
}

export function LeaderboardScreen({ offline = false }: { offline?: boolean }) {
  const { reset, signedIn, username, stats } = useApp()

  const rows = useMemo<Row[]>(() => {
    const all = signedIn ? [...SAMPLE, { name: username, score: stats.bestScore, me: true }] : SAMPLE
    return [...all].sort((a, b) => b.score - a.score).slice(0, 50)
  }, [signedIn, username, stats.bestScore])

  if (offline) {
    return (
      <Screen className="screen-leaderboard">
        <TopBar title="Leaderboard" />
        <div className="lb-offline">
          <span className="panel-mark">
            <WifiOff size={18} />
          </span>
          <Eyebrow>Offline</Eyebrow>
          <h2>Couldn’t reach the leaderboard</h2>
          <p>Check your connection. Your scores still save on this device.</p>
          <Btn icon={RotateCw} onClick={() => reset('leaderboard')}>
            Try again
          </Btn>
        </div>
      </Screen>
    )
  }

  return (
    <Screen className="screen-leaderboard">
      <TopBar title="Leaderboard" />
      <div className="lb-heading">
        <Eyebrow>Top 50 by best score</Eyebrow>
        <h2>
          Who’s <em>on top?</em>
        </h2>
      </div>
      <ol className="lb-list">
        {rows.map((row, i) => (
          <li key={`${row.name}-${i}`} className={`lb-row ${row.me ? 'me' : ''}`} aria-current={row.me ? 'true' : undefined}>
            <span className="lb-rank">{i + 1}</span>
            <span className="lb-name">
              {row.name}
              {row.me && <small>You</small>}
            </span>
            <strong>{row.score.toLocaleString()}</strong>
          </li>
        ))}
      </ol>
      {!signedIn && <p className="lb-note">Sign in to save your score and appear on this list.</p>}
    </Screen>
  )
}
