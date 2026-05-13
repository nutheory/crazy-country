extends LimboState

@export var animation_player: AnimationPlayer
@export var animation: StringName

func _update(delta: float) -> void:
	if agent.wants_to_turn():
		dispatch(&"dir_changed")
		return
		
	if agent.movement_input != Vector2.ZERO:
		dispatch(&"turn_done") # Moves transition forward to 'walk'
		return
		
	agent.velocity.x = move_toward(agent.velocity.x, 0, agent.SPEED)
	agent.velocity.z = move_toward(agent.velocity.z, 0, agent.SPEED)
	animation_player.play(animation)
