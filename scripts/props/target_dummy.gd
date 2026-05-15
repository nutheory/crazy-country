extends Node3D

@export var max_health: int = 6
@export var knockback_distance: float = 0.35

@onready var sprite: Sprite3D = $Sprite3D
@onready var hp_label: Label3D = $HpLabel

var current_health: int
var base_position: Vector3
var base_modulate: Color
var hit_tween: Tween
var is_resetting := false

func _ready() -> void:
	current_health = max_health
	base_position = position
	base_modulate = sprite.modulate
	_update_label()

func take_hit(amount: int, hit_origin: Vector3) -> void:
	if is_resetting:
		return

	current_health = maxi(current_health - amount, 0)
	_update_label()
	_play_hit_reaction(hit_origin)

	if current_health == 0:
		_reset_after_break()

func _play_hit_reaction(hit_origin: Vector3) -> void:
	var push_direction := global_position - hit_origin
	push_direction.y = 0.0

	if push_direction.length_squared() == 0.0:
		push_direction = Vector3.RIGHT

	push_direction = push_direction.normalized()

	if hit_tween:
		hit_tween.kill()

	sprite.modulate = Color(1.0, 0.35, 0.25)
	hit_tween = create_tween()
	hit_tween.tween_property(self, "position", base_position + push_direction * knockback_distance, 0.06)
	hit_tween.parallel().tween_property(sprite, "modulate", base_modulate, 0.12)
	hit_tween.tween_property(self, "position", base_position, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _reset_after_break() -> void:
	is_resetting = true
	hp_label.text = "broken"
	await get_tree().create_timer(0.8).timeout
	current_health = max_health
	is_resetting = false
	_update_label()

func _update_label() -> void:
	hp_label.text = "dummy %d/%d" % [current_health, max_health]
