const facts = [
  ["Offline first", "The whole game runs without a network. A guest sends nothing."],
  ["No ads, no purchases", "Nothing is for sale."],
  [
    "Global leaderboard",
    "Sign in to appear on it. Top 50 per category: Marathon, Sprint, Ultra and Daily.",
  ],
  [
    "Start at an unlocked level",
    "Marathon starts at any level from 1 to 10 you have unlocked. Level N opens at 10 × (N − 1) lines.",
  ],
  ["Music off by default", "Sound is on. Music waits until you switch it on."],
  ["Haptics", "A short vibration on line clears and game over. One switch turns it off."],
];

/** The short list: plain rows, revealed in turn as they scroll in. */
export function Facts() {
  return (
    <section className="wrap py-12 lg:py-24" aria-labelledby="facts-title">
      <h2 id="facts-title" className="reveal font-display text-2xl lg:text-4xl">
        The short list
      </h2>
      <ul className="reveal-stagger mt-6 flex flex-col divide-y divide-line border-y border-line lg:mt-10">
        {facts.map(([title, body]) => (
          <li
            key={title}
            className="grid gap-1 px-2 py-4 sm:grid-cols-[17rem_1fr] sm:gap-6 lg:py-5"
          >
            <span className="text-sm font-semibold">{title}</span>
            <span className="measure text-sm text-text-muted">{body}</span>
          </li>
        ))}
      </ul>
    </section>
  );
}
