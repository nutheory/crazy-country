extends LimboState

@export var animation_player: AnimationPlayer
@export var animation: StringName

func _update(delta: float) -> void:
	# 1. Intercept process if player switches input directions
	if agent.wants_to_turn():
		dispatch(&"dir_changed")
		return
		
	# 2. Transition back to idle if input completely stops
	if agent.movement_input == Vector2.ZERO:
		dispatch(&"turn_to_idle") # LimboHSM can reuse this or you can add a walk_to_idle transition
		return

	# 3. Apply standard locomotion
	agent.apply_movement(delta)
	animation_player.play(animation)
