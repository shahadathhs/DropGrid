'use client'

import { useMemo } from 'react'

const PIECES = [
  { color: '#55dde0', cells: [[0, 0], [1, 0], [2, 0], [3, 0]] },
  { color: '#6688ff', cells: [[0, 0], [0, 1], [1, 1], [2, 1]] },
  { color: '#ffaa5c', cells: [[2, 0], [0, 1], [1, 1], [2, 1]] },
  { color: '#f6d365', cells: [[1, 0], [2, 0], [1, 1], [2, 1]] },
  { color: '#69d69b', cells: [[1, 0], [2, 0], [0, 1], [1, 1]] },
  { color: '#b38cff', cells: [[1, 0], [0, 1], [1, 1], [2, 1]] },
  { color: '#ff83b8', cells: [[0, 0], [1, 0], [1, 1], [2, 1]] },
]

const SETTLED: Array<readonly [number, number, string]> = [
  ...[0, 1, 2, 3].map((x) => [x, 17, '#6688ff'] as const),
  ...[4, 5, 6].map((x) => [x, 17, '#b38cff'] as const),
  ...[7, 8, 9].map((x) => [x, 17, '#ff83b8'] as const),
  ...[0, 1, 2].map((x) => [x, 18, '#6688ff'] as const),
  ...[3, 4, 5].map((x) => [x, 18, '#b38cff'] as const),
  ...[6, 7, 8].map((x) => [x, 18, '#ff83b8'] as const),
  [9, 18, '#69d69b'] as const,
  ...[0, 1, 2, 3].map((x) => [x, 19, '#55dde0'] as const),
  ...[4, 5, 6].map((x) => [x, 19, '#f6d365'] as const),
  ...[7, 8, 9].map((x) => [x, 19, '#ffaa5c'] as const),
]

function Cell({ color, ghost = false }: { color: string; ghost?: boolean }) {
  return (
    <span
      className="cell"
      style={{
        backgroundColor: ghost ? `${color}16` : color,
        borderColor: ghost ? `${color}55` : `${color}cc`,
      }}
    />
  )
}

export function Board() {
  const active = PIECES[5]
  const cells = useMemo(
    () => [
      ...SETTLED.map(([x, y, color]) => ({ x, y, color })),
      ...active.cells.map(([x, y]) => ({ x: x + 3, y: y + 3, color: active.color })),
    ],
    [active],
  )

  return (
    <div className="board" aria-label="Game board">
      {Array.from({ length: 200 }).map((_, i) => {
        const x = i % 10
        const y = Math.floor(i / 10)
        const filled = cells.find((c) => c.x === x && c.y === y)
        const ghost = !filled && active.cells.some(([cx, cy]) => cx + 3 === x && cy + 12 === y)
        return (
          <div key={i} className="board-cell">
            {filled ? <Cell color={filled.color} /> : ghost ? <Cell color={active.color} ghost /> : null}
          </div>
        )
      })}
    </div>
  )
}

export function NextPiece() {
  return (
    <span className="next-piece" aria-label="Next piece">
      <i />
      <i />
      <i />
      <i />
    </span>
  )
}
