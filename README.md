# Crazy Country

Small Godot 4.6 prototype for experimenting with a 3D player controller, sprite-sheet animations, and LimboAI state machines.

## Run it

1. Open this folder in Godot 4.6.
2. Run the default scene, `scenes/main.tscn`.

If the Godot CLI is available:

```sh
godot --path .
```

## Controls

| Action | Keyboard |
| --- | --- |
| Move | WASD |
| Run | Q |
| Charge | L |
| Jump | Space |
| Punch | U |
| Kick | I |
| Nut tap | O |
| Headbutt | P |

## Good First Files

- `scenes/main.tscn`: the world, ground, player instance, lighting, and HUD label.
- `scenes/agents/player/player.tscn`: the player nodes and animation library.
- `scripts/agents/player/player.gd`: shared player movement, input checks, and state-machine wiring.
- `scripts/agents/player/states/*.gd`: one file per player state.
- `scenes/props/target_dummy.tscn`: the target dummy placed in the arena.
- `scripts/props/target_dummy.gd`: dummy health, hit flash, knockback, and reset behavior.
- `docs/enhancement-notes.md`: a short explanation of the first enhancement pass.
