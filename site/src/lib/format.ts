/** Commas every three digits, as the game writes numbers (ui_format.gd thousands). */
export function thousands(value: number): string {
  const digits = String(Math.abs(value));
  const grouped = digits.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  return value < 0 ? `-${grouped}` : grouped;
}
