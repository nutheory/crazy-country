extends LimboState

@export var animation_player: AnimationPlayer
@export var animation: StringName

var target_direction: String = "right"

func _enter() -> void:
	# 1. Lock character horizontal velocity during the pivot frame sequence
	agent.velocity.x = 0.0
	agent.velocity.z = 0.0
	
	# 2. Determine target side based on current orientation
	if agent.current_direction == "right":
		target_direction = "left"
		animation_player.play(animation)
	else:
		target_direction = "right"
		animation_player.play(animation)
		
	# 3. Yield logic sequence execution until the specific animation completes
	wait_for_turn_completion()

func wait_for_turn_completion() -> void:
	await animation_player.animation_finished
	
	# 4. Permanently apply visual flip and update global tracking states
	agent.current_direction = target_direction
	agent.sprite.flip_h = (target_direction == "left")
	
	# 5. Route the user back into the appropriate movement node
	if agent.movement_input != Vector2.ZERO:
		dispatch(&"turn_done")
	else:
		dispatch(&"turn_to_idle")
