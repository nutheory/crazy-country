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
- Added a target dummy that takes damage, flashes, pops backward, and resets after breaking.

## Why This Shape

The project already uses a state machine, so the changes stay inside that pattern instead of replacing it. That makes the next lesson clear: when you want a new player action, add or update a state, wire a transition in `player.gd`, and make sure the scene has the matching animation.

The dummy uses a small `Area3D` hurtbox and the player uses one reusable `AttackHitbox`. The attack state decides how much damage to deal, while `player.gd` handles finding a target. That keeps damage behavior in one place and makes each attack state easy to read.

## Possible Next Lessons

- Add a sound effect when the dummy is hit.
- Make the attack hitbox active only on specific animation frames.
- Add a camera that follows from a cleaner angle.
- Add a simple enemy that walks toward the player.
- Replace the static HUD label with a pause/help menu.

## Combo Ability Slice

The combo pass keeps the same learning-friendly shape:

1. Each attack state reports a named combo step when it starts.
2. `player.gd` keeps a short timed combo history and matches the newest steps against known sequences.
3. A `Label3D` over Claire shows one random yell line for the matched combo.

Current combos:

- Punch, Kick: Clipboard Clobber
- Kick, Headbutt: Headfirst Grant
- Punch, Nut tap, Headbutt: Claire Protocol
- Nut tap, Kick, Punch: Facility Recalibration

Attack states also listen for a different attack button while their animation is active, so combos can begin to feel chained instead of only happening after a full reset to idle.

The next clean step is to move combo definitions out of `player.gd` once there are more characters. A character bio can own its ability themes, combo sequences, and yell pools, while the player state machine keeps doing the same generic combo matching.
