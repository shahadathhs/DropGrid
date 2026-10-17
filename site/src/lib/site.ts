import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * The two grounds and the piece colors, mirrored from game/scripts/palette.gd.
 * Keep in sync — the site never invents a color.
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

export const repo = "https://github.com/shahadathhs/DropGrid";
export const apiBase = "https://dropgrid-api.onrender.com";
export const downloadUrl = `${repo}/releases/latest`;
