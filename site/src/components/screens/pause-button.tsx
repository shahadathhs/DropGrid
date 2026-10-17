/** The pause tile at the end of the HUD row: two bars, as assets/icons/pause.svg draws them. */
export function PauseButton() {
  return (
    <span className="pause-btn">
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="3"
        strokeLinecap="butt"
        strokeLinejoin="miter"
      >
        <path d="M8.5 4v16M15.5 4v16" />
      </svg>
    </span>
  );
}
