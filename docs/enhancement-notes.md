# Enhancement Notes

This repo is a good learning project because the player is built from small, named pieces:

1. `player.gd` owns shared facts such as speed, input checks, and state-machine transitions.
2. Each file in `scripts/agents/player/states/` owns one player behavior.
3. `player.tscn` connects those scripts to the `AnimationPlayer` and sprite-sheet animations.

## First Enhancement Pass

The first changes are intentionally small:

- Fixed punch and kick input checks so `U` punches and `I` kicks.
- Made jump actually set upward velocity.
- Added the missing jump animation to the player animation library.
- Kept the player in the jump state until landing, then routed back to idle, walk, run, or charge.
- Added a small control hint label to `scenes/main.tscn`.

## Why This Shape

The project already uses a state machine, so the changes stay inside that pattern instead of replacing it. That makes the next lesson clear: when you want a new player action, add or update a state, wire a transition in `player.gd`, and make sure the scene has the matching animation.

## Possible Next Lessons

- Add a simple enemy target dummy.
- Add hitboxes for punch and kick.
- Add health to the dummy.
- Add a camera that follows from a cleaner angle.
- Replace the static HUD label with a pause/help menu.
