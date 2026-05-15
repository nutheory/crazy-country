extends LimboState

@export var animation_player: AnimationPlayer
@export var animation: StringName

# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	agent.velocity.x = 0.0
	agent.velocity.z = 0.0
	
	animation_player.play(animation)
	agent.start_attack(1, &"punch")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update(_delta: float) -> void:
	agent.check_attack_chain_input(&"punch")
