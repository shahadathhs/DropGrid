import { grounds } from "@/lib/tokens";

const g = grounds.dark;

/**
 * What the iframe shows before the visitor asks for the game: a tiny document
 * of its own (it cannot see the page's CSS, so the tokens are inlined). Its one
 * link navigates the iframe itself to the game, so nothing heavy loads until
 * Play is pressed and no script is involved.
 */
const poster = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>
html,body{height:100%;margin:0}
body{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1.5rem;background:${g.background};color:${g.ink};font:16px/1.4 "Martian Mono",ui-monospace,Menlo,Consolas,monospace;text-align:center}
h1{margin:0;font-size:1.75rem;font-weight:400;letter-spacing:0.02em}
p{margin:0;font-size:0.8125rem;color:#a09a8e}
a{display:inline-block;padding:0.75rem 1.5rem;border-radius:4px;background:${g.ink};color:${g.background};font:inherit;font-size:0.875rem;font-weight:600;text-decoration:none}
a:hover,a:focus-visible{opacity:0.86}
a:focus-visible{outline:2px solid ${g.ink};outline-offset:3px}
a{transition:opacity 120ms linear}
</style></head><body><h1>DropGrid</h1><p>Runs in this page. Starts when you press Play.</p><a href="/play/game/index.html" target="_self">Play</a></body></html>`;

/** The game's web export in an iframe. 9:16 is the game's 720 x 1280 design. */
export function Playground() {
  return (
    <iframe
      name="playground"
      title="DropGrid, playable in the browser"
      srcDoc={poster}
      sandbox="allow-scripts allow-same-origin"
      allow="fullscreen"
      className="block aspect-[9/16] w-full border-0 bg-background"
    />
  );
}
