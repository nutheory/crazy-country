extends LimboState

@export var animation_player: AnimationPlayer
@export var animation: StringName

func _update(delta: float) -> void:
	agent.check_run_input()
	agent.check_jump_input()
	agent.check_kick_input()
	agent.check_punch_input()
	agent.check_nut_tap_input()
	agent.check_headbutt_input()

	if agent.wants_to_turn():
		dispatch(&"dir_changed")
		return
		
	if agent.movement_input == Vector2.ZERO:
		dispatch(&"turn_to_idle") # LimboHSM can reuse this or you can add a walk_to_idle transition
		return

	agent.apply_movement(delta)
	animation_player.play(animation)
