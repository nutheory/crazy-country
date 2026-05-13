extends LimboState

@export var animation_player: AnimationPlayer
@export var animation: StringName

func _enter() -> void:
	animation_player.play(animation)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _update(delta: float) -> void:
	agent.apply_movement(delta)
	
	if agent.movement_input == Vector2.ZERO:
		get_root().dispatch("to_idle")
