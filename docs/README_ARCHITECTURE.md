# Technical Architecture — Godot 4.x

## 1. Architectural approach

Use a small, understandable scene-based architecture. Avoid building a framework for a game this size. The board rules should be testable independently from UI presentation as much as practical.

Use Godot 4.x with GDScript. Confirm the exact Godot version before starting and do not mix Godot 3 APIs with Godot 4 APIs.

## 2. Suggested project structure

```text
res://
├── project.godot
├── scenes/
│   ├── main_menu.tscn
│   ├── game.tscn
│   ├── game_over_overlay.tscn
│   └── pause_overlay.tscn
├── scripts/
│   ├── game_controller.gd
│   ├── board_model.gd
│   ├── piece_data.gd
│   ├── piece_view.gd
│   ├── touch_controls.gd
│   ├── hud_controller.gd
│   └── save_manager.gd
├── resources/
│   ├── game_theme.tres
│   └── piece_definitions.gd
├── assets/
│   ├── fonts/
│   ├── audio/
│   └── icons/
└── README_*.md
```

This is a proposed starting point, not a requirement to create every file immediately. Prefer fewer files if combining responsibilities makes the first version clearer. Do not create empty scripts or scenes just to match the tree.

## 3. Responsibilities

### `main_menu.tscn`
- Displays title, Play, Settings, and best score.
- Starts the game scene.
- Does not contain board rules.

### `game.tscn`
- Contains the board view, HUD, touch controls, and pause/game-over overlays.
- Connects gameplay events to UI updates.
- Should not duplicate board collision or line-clearing rules.

### `game_controller.gd`
- Owns the game flow and active piece.
- Coordinates piece spawning, fall timer, movement requests, locking, line clears, scoring, levels, pause, and game-over.
- Communicates state changes to the HUD via signals or clear method calls.

### `board_model.gd`
- Owns the logical grid and occupied cells.
- Checks whether a piece placement is valid.
- Locks pieces into the grid.
- Detects and clears completed lines.
- Does not depend on screen coordinates or UI nodes.

### `piece_data.gd` / piece definitions
- Represents piece cell offsets, rotation state, and type.
- Keeps shape data separate from visual nodes.
- Use a simple representation that is easy to inspect and debug.

### `piece_view.gd`
- Draws or updates the visible cells for the active piece and locked board.
- Converts logical grid positions into screen positions.
- Does not decide whether a move is legal.

### `touch_controls.gd`
- Converts UI button presses into gameplay actions.
- Does not directly edit board state.
- Optional keyboard input may route through the same action methods.

### `hud_controller.gd`
- Updates score, level, lines, and best score.
- Shows pause and game-over overlays.
- Should not calculate scoring independently.

### `save_manager.gd`
- Loads and saves best score and settings in local user data.
- Handles missing/corrupt data gracefully.

## 4. Communication

Prefer explicit signals or clear method calls over tight coupling and searching the scene tree for nodes at runtime.

Examples of useful events:
- `score_changed(score)`
- `lines_changed(total_lines)`
- `level_changed(level)`
- `piece_locked`
- `lines_cleared(count)`
- `game_over(final_score)`
- `pause_changed(is_paused)`

Do not introduce a global singleton/autoload unless there is a concrete reason. For this small game, a local save manager or a small autoload may be enough; choose one approach and document it.

## 5. Data and coordinate rules

- Use integer grid coordinates for all gameplay rules.
- Keep grid coordinates separate from pixel positions.
- Establish one coordinate convention and use it consistently.
- Represent empty cells consistently (for example, `null` or a documented empty value).
- Centralize board dimensions, cell size, fall intervals, scoring, and level thresholds.
- Avoid duplicating magic numbers across scripts.

## 6. Rendering approach

For a small grid, use a straightforward 2D rendering approach. Possible options include a `TileMapLayer`, individual `ColorRect`/`Control` cells, or custom drawing. Pick the approach that best fits a polished responsive UI and the selected Godot version. Do not combine several rendering systems without a clear benefit.

Separate:
- **Model:** board occupancy and rules.
- **Controller:** current game state and transitions.
- **View:** rendering and animation.
- **Input:** touch/keyboard action mapping.

## 7. State management

Use a small explicit state model, for example:
- `MENU`
- `PLAYING`
- `PAUSED`
- `GAME_OVER`

Make transitions intentional. A paused or game-over game must not continue advancing the fall timer or accepting normal movement input.

## 8. Quality rules

- Use typed GDScript where it improves clarity.
- Give variables and functions descriptive names.
- Keep functions small and focused.
- Avoid unnecessary third-party plugins.
- Avoid external APIs, analytics, ads, authentication, and networking.
- Add comments for non-obvious logic, not for every line.
- Handle errors rather than silently ignoring them.
- Do not claim a feature is complete unless it is implemented and tested.
