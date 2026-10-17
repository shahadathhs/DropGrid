import { cn } from "@/lib/cn";
import { CONTROL_ROW } from "@/lib/controls";
import { ControlGlyph } from "@/components/screens/control-glyph";
import { Fragment } from "react";

/**
 * The control row under the board, drawn with the game's own button styles.
 * `mirrored` is the Left-handed setting: the layout direction flips, so the
 * order reverses and hard drop moves to the left.
 */
export function ControlPad({ mirrored = false }: { mirrored?: boolean }) {
  return (
    <div className={cn("pad", mirrored && "pad--rtl")} aria-hidden>
      <div className="controls controls--hold">
        {CONTROL_ROW.map((c) => (
          <Fragment key={c.id}>
            {c.drop ? <span className="ctl-gap" /> : null}
            <ControlGlyph control={c} />
          </Fragment>
        ))}
      </div>
    </div>
  );
}
