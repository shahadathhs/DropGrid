#!/usr/bin/env python3
"""Generate the Android launcher icons from the GRID mark.

The mark is four rounded cells in piece colors on the graphite ground —
the same shapes as site/public/icon.svg and game/scripts/brand_mark.gd.
Run from the repo root:  uv run --with pillow scripts/make_app_icons.py

Colors are copied from game/scripts/palette.gd (dark ground). Change them
there first, then here, then in site/src/lib/tokens.ts.
"""

from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path("game/assets/icons/app")
GROUND = "#161513"
CELLS = ["#96DCE6", "#F6E292", "#874CCB", "#F59F5D"]  # I O T L, matching BrandMark
SS = 4  # supersampling factor for clean corners


def grid_image(size: int, block_ratio: float, canvas_radius: float, cell_radius: float) -> Image.Image:
    """Canvas of `size` px; a centered 2x2 cell grid filling `block_ratio` of it."""
    img = Image.new("RGB", (size * SS, size * SS), GROUND)
    d = ImageDraw.Draw(img)
    if canvas_radius:
        # Round the canvas corners themselves (legacy icons are shown unmasked).
        mask = Image.new("L", img.size, 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            [0, 0, img.size[0] - 1, img.size[1] - 1], radius=canvas_radius * SS, fill=255
        )
        base = Image.new("RGB", img.size, "#000000")
        img = Image.composite(img, base, mask)
        d = ImageDraw.Draw(img)

    block = size * block_ratio
    cell = block / 2 * 0.88  # 12% of the half-cell is the gap
    offset = (size - block) / 2
    radius = cell * cell_radius
    for i, color in enumerate(CELLS):
        x = offset + (i % 2) * (block / 2)
        y = offset + (i // 2) * (block / 2)
        d.rounded_rectangle(
            [x * SS, y * SS, (x + cell) * SS, (y + cell) * SS],
            radius=radius * SS,
            fill=color,
        )
    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    # Adaptive layers: 432x432; the grid stays inside the 66/108 safe circle.
    grid_image(432, 0.54, 0, 0.24).save(OUT / "adaptive_foreground_432.png")
    Image.new("RGB", (432, 432), GROUND).save(OUT / "adaptive_background_432.png")
    # Legacy: 192x192, slightly rounded canvas, larger grid.
    grid_image(192, 0.62, 0.19, 0.24).save(OUT / "main_192.png")
    for f in sorted(OUT.iterdir()):
        print(f)


if __name__ == "__main__":
    main()
