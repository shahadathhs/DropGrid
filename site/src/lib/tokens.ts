/**
 * The two grounds and the piece colors, mirrored from game/scripts/palette.gd.
 * The palette in the game is law — this file never invents a color, and any
 * change there is copied here in the same change.
 */
export const grounds = {
  dark: {
    label: "Graphite",
    background: "#161513",
    cell: "#262320",
    ink: "#ece7dc",
  },
  light: {
    label: "Paper",
    background: "#efebe2",
    cell: "#e3ded2",
    ink: "#1b1a17",
  },
} as const;

export const pieceColors = [
  "#96dce6",
  "#f6e292",
  "#874ccb",
  "#58c083",
  "#db548c",
  "#265ab4",
  "#f59f5d",
] as const;
