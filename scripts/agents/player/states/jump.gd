extends LimboState

@export var animation_player: AnimationPlayer
@export var animation: StringName

var has_left_floor := false

func _enter() -> void:
	has_left_floor = false
	agent.velocity.y = agent.JUMP_VELOCITY
	animation_player.play(animation)


func _update(delta: float) -> void:
	if agent.wants_to_turn():
		agent.face_movement_direction()

	agent.apply_movement(delta)

	if not agent.is_on_floor():
		has_left_floor = true

	if has_left_floor and agent.is_on_floor() and agent.velocity.y <= 0.0:
		agent.dispatch_landing_state()
