/** Back button and heading, as the game's secondary screens begin. */
export function ScreenTop({ title }: { title: string }) {
  return (
    <>
      <div className="scr-back">Back</div>
      <div className="scr-heading">{title}</div>
    </>
  );
}
