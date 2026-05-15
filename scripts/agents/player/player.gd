extends CharacterBody3D

@export var state_machine: LimboHSM

@onready var idle_state = $LimboHSM/Idle
@onready var walk_state = $LimboHSM/Walk
@onready var run_state = $LimboHSM/Run
@onready var charge_state = $LimboHSM/Charge
@onready var turn_state = $LimboHSM/Turn
@onready var jump_state = $LimboHSM/Jump
@onready var punch_state = $LimboHSM/Punch
@onready var kick_state = $LimboHSM/Kick
@onready var nut_tap_state = $LimboHSM/NutTap
@onready var headbutt_state = $LimboHSM/Headbutt

@onready var sprite = $Sprite3D
@onready var attack_hitbox: Area3D = $AttackHitbox
@onready var attack_hitbox_shape: CollisionShape3D = $AttackHitbox/CollisionShape3D

const SPEED = 5.0
const RUN_SPEED_MULTIPLIER = 2.0
const CHARGE_SPEED_MULTIPLIER = 2.6
const JUMP_VELOCITY = 8.0
const ATTACK_HITBOX_ACTIVE_TIME = 0.18
const ATTACK_ANIMATIONS: Array[StringName] = [&"Punch", &"Foot", &"Nuts", &"Headbutt"]

var movement_input: Vector2 = Vector2.ZERO
var current_direction: String = "right"
var move_type: String = "walk"
var current_attack_damage := 1
var current_attack_id := 0
var attack_targets_hit: Array[Node] = []

func _ready() -> void:
	_initialize_attack_hitbox()
	_initialize_state_machine()

func _initialize_attack_hitbox() -> void:
	attack_hitbox.monitoring = false
	attack_hitbox_shape.disabled = true
	attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)
	
func _initialize_state_machine() -> void:
	state_machine.add_transition(idle_state, turn_state, &"dir_changed")
	state_machine.add_transition(walk_state, turn_state, &"dir_changed")
	state_machine.add_transition(run_state, turn_state, &"dir_changed")
	state_machine.add_transition(charge_state, turn_state, &"dir_changed")

	state_machine.add_transition(idle_state, walk_state, &"turn_done")
	state_machine.add_transition(walk_state, idle_state, &"turn_to_idle")

	state_machine.add_transition(turn_state, walk_state, &"turn_done")
	state_machine.add_transition(turn_state, idle_state, &"turn_to_idle")

	state_machine.add_transition(state_machine.ANYSTATE, idle_state, &"to_idle")
	state_machine.add_transition(state_machine.ANYSTATE, walk_state, &"to_walk")
	state_machine.add_transition(state_machine.ANYSTATE, charge_state, &"to_charge")
	state_machine.add_transition(state_machine.ANYSTATE, run_state, &"to_run")
	state_machine.add_transition(state_machine.ANYSTATE, jump_state, &"to_jump")
	state_machine.add_transition(state_machine.ANYSTATE, punch_state, &"to_punch")
	state_machine.add_transition(state_machine.ANYSTATE, kick_state, &"to_kick")
	state_machine.add_transition(state_machine.ANYSTATE, nut_tap_state, &"to_nut_tap")
	state_machine.add_transition(state_machine.ANYSTATE, headbutt_state, &"to_headbutt")
	
	# Setup State Machine
	state_machine.initial_state = idle_state
	state_machine.initialize(self )
	state_machine.set_active(true)
	
func check_move_mode_input() -> void:
	if is_on_floor() and Input.is_action_pressed("run"):
		move_type = "run"
		state_machine.dispatch("to_run")
	elif is_on_floor() and Input.is_action_pressed("charge"):
		move_type = "charge"
		state_machine.dispatch("to_charge")
	else: 
		move_type = "walk"
		state_machine.dispatch("to_walk")
	
func check_headbutt_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("headbutt"):
		state_machine.dispatch("to_headbutt")

func check_nut_tap_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("nut_tap"):
		state_machine.dispatch("to_nut_tap")

func check_punch_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("punch"):
		state_machine.dispatch("to_punch")

func check_kick_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("kick"):
		state_machine.dispatch("to_kick")

func check_jump_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.dispatch("to_jump")

func dispatch_landing_state() -> void:
	if movement_input == Vector2.ZERO:
		state_machine.dispatch("to_idle")
	else:
		check_move_mode_input()

func wants_to_turn() -> bool:
	if movement_input.x > 0 and current_direction == "left":
		return true
	if movement_input.x < 0 and current_direction == "right":
		return true
	return false

func face_movement_direction() -> void:
	if movement_input.x > 0:
		current_direction = "right"
	elif movement_input.x < 0:
		current_direction = "left"
	else:
		return

	sprite.flip_h = (current_direction == "left")

func start_attack(damage: int) -> void:
	current_attack_id += 1
	current_attack_damage = damage
	attack_targets_hit.clear()
	_position_attack_hitbox()
	_set_attack_hitbox_active(true)
	_check_current_attack_overlaps(current_attack_id)
	_stop_current_attack_after(current_attack_id, ATTACK_HITBOX_ACTIVE_TIME)

func _position_attack_hitbox() -> void:
	var facing_offset := 1.35

	if current_direction == "left":
		facing_offset = -1.35

	attack_hitbox.position = Vector3(sprite.position.x + facing_offset, 0.3, sprite.position.z + 0.1)

func _set_attack_hitbox_active(is_active: bool) -> void:
	attack_hitbox.monitoring = is_active
	attack_hitbox_shape.disabled = not is_active

func _check_current_attack_overlaps(attack_id: int) -> void:
	await get_tree().physics_frame

	if attack_id != current_attack_id:
		return

	for area in attack_hitbox.get_overlapping_areas():
		_try_hit_area(area)

func _stop_current_attack_after(attack_id: int, active_time: float) -> void:
	await get_tree().create_timer(active_time).timeout

	if attack_id == current_attack_id:
		_set_attack_hitbox_active(false)

func _on_attack_hitbox_area_entered(area: Area3D) -> void:
	_try_hit_area(area)

func _try_hit_area(area: Area3D) -> void:
	var receiver := _find_damage_receiver(area)

	if receiver == null or receiver in attack_targets_hit:
		return

	attack_targets_hit.append(receiver)
	receiver.take_hit(current_attack_damage, attack_hitbox.global_position)

func _find_damage_receiver(area: Area3D) -> Node:
	var current_node: Node = area

	while current_node:
		if current_node != self and current_node.has_method("take_hit"):
			return current_node

		current_node = current_node.get_parent()

	return null
	
func apply_movement(_delta) -> void:
	if move_type == "run":
		velocity.x = movement_input.x * (SPEED * RUN_SPEED_MULTIPLIER)
		velocity.z = movement_input.y * (SPEED * RUN_SPEED_MULTIPLIER)
	elif move_type == "charge":
		velocity.x = movement_input.x * (SPEED * CHARGE_SPEED_MULTIPLIER)
		velocity.z = movement_input.y * (SPEED * CHARGE_SPEED_MULTIPLIER)
	else:
		velocity.x = movement_input.x * SPEED
		velocity.z = movement_input.y * SPEED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	movement_input = Input.get_vector("left", "right", "up", "down")


	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ATTACK_ANIMATIONS:
		state_machine.dispatch("to_idle")
