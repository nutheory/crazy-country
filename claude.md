# Claude Notes for Crazy Country

## Project overview
- Engine: Godot `4.6` (see `project.godot`)
- Main scene: `res://scenes/main.tscn`
- Core tech in repo:
  - 3D prototype/player work under `scenes/` and `scripts/`
  - LimboAI demo/content under `demo/`
  - LimboAI addon code under `addons/limboai/`

## Local run workflow
1. Open the project root in Godot 4.6.
2. Run the main scene (`scenes/main.tscn`) or project default run target.
3. For AI behavior examples, run `demo/scenes/showcase.tscn` or `demo/scenes/game.tscn`.

If the Godot CLI is installed, a typical command is:
- `godot --path .`

## Important file map
- `project.godot`: project settings/input map/engine config.
- `scenes/main.tscn`: top-level 3D scene.
- `scenes/agents/player/player.tscn`: player scene used by main.
- `scripts/agents/player/player.gd`: player movement/state machine wiring.
- `scripts/agents/player/states/*.gd`: player states (`idle`, `walk`, `turn`).
- `demo/ai/tasks/*.gd`: behavior tree tasks/conditions for demo agents.
- `demo/scenes/showcase.gd`: behavior tree visual showcase logic.
- `demo/scenes/game.gd`: wave-based demo game loop.

## Coding conventions
- Language: GDScript.
- Keep typed variables and explicit return types where present.
- Preserve existing indentation style (tabs are used throughout `.gd` files).
- Follow existing naming patterns:
  - `snake_case` for variables/functions
  - `StringName` literals with `&"..."` when used in transitions/events.
- Prefer small, focused edits and avoid broad renames unless requested.

## Change guidance
- Prefer editing game scripts/scenes in the relevant subtree (`scripts/` vs `demo/`) instead of cross-cutting changes.
- Treat `project.godot` edits cautiously; Godot comments indicate editor-based changes are preferred.
- When changing player behavior, verify corresponding state transitions in:
  - `scripts/agents/player/player.gd`
  - `scripts/agents/player/states/*.gd`
- When changing AI behavior demo logic, verify both:
  - task implementation in `demo/ai/tasks/*.gd`
  - behavior usage from loaded demo agents/scenes.

## Validation checklist
- Project opens without script errors.
- Main scene runs and player movement/jump still works.
- Any touched state machine transitions still dispatch expected events.
- For demo AI edits, run showcase or game scene and confirm no runtime errors.
