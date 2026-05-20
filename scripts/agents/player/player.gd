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
@onready var combo_callout: Label3D = $ComboCallout
@onready var attack_hitbox: Area3D = $AttackHitbox
@onready var attack_hitbox_shape: CollisionShape3D = $AttackHitbox/CollisionShape3D

const SPEED = 5.0
const RUN_SPEED_MULTIPLIER = 2.0
const CHARGE_SPEED_MULTIPLIER = 2.6
const JUMP_VELOCITY = 8.0
const ATTACK_HITBOX_ACTIVE_TIME = 0.18
const COMBO_INPUT_WINDOW = 2.2
const COMBO_CALLOUT_TIME = 1.8
const COMBO_HISTORY_LIMIT = 4
const ATTACK_ANIMATIONS: Array[StringName] = [&"Punch", &"Foot", &"Nuts", &"Headbutt"]
const COMBO_DEFINITIONS = [
	{
		"id": &"clipboard_clobber",
		"sequence": [&"punch", &"kick"],
		"blurbs": [
			"Form 12-B says eat this!",
			"Stamp it and slam it!",
			"Training facility certified!"
		],
	},
	{
		"id": &"headfirst_grant",
		"sequence": [&"kick", &"headbutt"],
		"blurbs": [
			"Physics called in sick!",
			"Head-first scholarship!",
			"Helmet optional!"
		],
	},
	{
		"id": &"claire_protocol",
		"sequence": [&"punch", &"nut_tap", &"headbutt"],
		"blurbs": [
			"Claire protocol: unacceptable!",
			"Abduction lab approved!",
			"Southern science, baby!"
		],
	},
	{
		"id": &"facility_recalibration",
		"sequence": [&"nut_tap", &"kick", &"punch"],
		"blurbs": [
			"Recalibrate the interns!",
			"This is lab work!",
			"Put that in the clipboard!"
		],
	},
]

var movement_input: Vector2 = Vector2.ZERO
var current_direction: String = "right"
var move_type: String = "walk"
var current_attack_damage := 1
var current_attack_id := 0
var attack_targets_hit: Array[Node] = []
var combo_history: Array[StringName] = []
var last_combo_step_msec := 0
var attack_input_lock_frame := -1
var combo_callout_id := 0
var combo_rng := RandomNumberGenerator.new()

func _ready() -> void:
	combo_rng.randomize()
	combo_callout.visible = false
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
	
func check_headbutt_input() -> bool:
	if _can_start_ground_attack() and Input.is_action_just_pressed("headbutt"):
		state_machine.dispatch("to_headbutt")
		return true
	return false

func check_nut_tap_input() -> bool:
	if _can_start_ground_attack() and Input.is_action_just_pressed("nut_tap"):
		state_machine.dispatch("to_nut_tap")
		return true
	return false

func check_punch_input() -> bool:
	if _can_start_ground_attack() and Input.is_action_just_pressed("punch"):
		state_machine.dispatch("to_punch")
		return true
	return false

func check_kick_input() -> bool:
	if _can_start_ground_attack() and Input.is_action_just_pressed("kick"):
		state_machine.dispatch("to_kick")
		return true
	return false

func check_attack_chain_input(current_step: StringName) -> bool:
	if not _can_start_ground_attack():
		return false

	if current_step != &"kick" and Input.is_action_just_pressed("kick"):
		state_machine.dispatch("to_kick")
		return true
	if current_step != &"punch" and Input.is_action_just_pressed("punch"):
		state_machine.dispatch("to_punch")
		return true
	if current_step != &"nut_tap" and Input.is_action_just_pressed("nut_tap"):
		state_machine.dispatch("to_nut_tap")
		return true
	if current_step != &"headbutt" and Input.is_action_just_pressed("headbutt"):
		state_machine.dispatch("to_headbutt")
		return true

	return false

func check_jump_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.dispatch("to_jump")

func _can_start_ground_attack() -> bool:
	return is_on_floor() and Engine.get_physics_frames() != attack_input_lock_frame

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

func start_attack(damage: int, combo_step: StringName = &"") -> void:
	if combo_step != &"":
		record_combo_step(combo_step)

	current_attack_id += 1
	current_attack_damage = damage
	attack_targets_hit.clear()
	_position_attack_hitbox()
	_set_attack_hitbox_active(true)
	_check_current_attack_overlaps(current_attack_id)
	_stop_current_attack_after(current_attack_id, ATTACK_HITBOX_ACTIVE_TIME)

func record_combo_step(step: StringName) -> void:
	var now := Time.get_ticks_msec()
	var seconds_since_last_step := float(now - last_combo_step_msec) / 1000.0

	attack_input_lock_frame = Engine.get_physics_frames()

	if last_combo_step_msec > 0 and seconds_since_last_step > COMBO_INPUT_WINDOW:
		combo_history.clear()

	last_combo_step_msec = now
	combo_history.append(step)

	while combo_history.size() > COMBO_HISTORY_LIMIT:
		combo_history.pop_front()

	var combo := _find_completed_combo()

	if not combo.is_empty():
		_show_combo_callout(combo)

func _find_completed_combo() -> Dictionary:
	var best_combo := {}
	var best_sequence_size := 0

	for combo in COMBO_DEFINITIONS:
		var sequence: Array = combo["sequence"]

		if sequence.size() > best_sequence_size and _combo_history_ends_with(sequence):
			best_combo = combo
			best_sequence_size = sequence.size()

	return best_combo

func _combo_history_ends_with(sequence: Array) -> bool:
	if sequence.size() > combo_history.size():
		return false

	var history_start := combo_history.size() - sequence.size()

	for index in range(sequence.size()):
		if combo_history[history_start + index] != sequence[index]:
			return false

	return true

func _show_combo_callout(combo: Dictionary) -> void:
	var blurbs: Array = combo["blurbs"]

	if blurbs.is_empty():
		return

	combo_callout_id += 1
	combo_callout.text = str(blurbs[combo_rng.randi_range(0, blurbs.size() - 1)])
	combo_callout.visible = true
	_hide_combo_callout_after(combo_callout_id, COMBO_CALLOUT_TIME)

func _hide_combo_callout_after(callout_id: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout

	if callout_id == combo_callout_id:
		combo_callout.visible = false

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
