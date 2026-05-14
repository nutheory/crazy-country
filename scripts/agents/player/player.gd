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

const SPEED = 5.0
const JUMP_VELOCITY = 8

var movement_input: Vector2 = Vector2.ZERO
var current_direction: String = "right"
var move_type: String = "walk"

func _ready():
	_initialize_state_machine()
	
func _initialize_state_machine() -> void:
	state_machine.add_transition(idle_state, turn_state, &"dir_changed")
	state_machine.add_transition(walk_state, turn_state, &"dir_changed")

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
	
func check_run_input() -> void:
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
	if is_on_floor() and Input.is_action_just_pressed("kick"):
		state_machine.dispatch("to_kick")

func check_kick_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("punch"):
		state_machine.dispatch("to_punch")

func check_jump_input() -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.dispatch("to_jump")

func wants_to_turn() -> bool:
	if movement_input.x > 0 and current_direction == "left":
		return true
	if movement_input.x < 0 and current_direction == "right":
		return true
	return false
	
func apply_movement(_delta) -> void:
	if move_type == "run":
		velocity.x = movement_input.x * (SPEED * 2)
		velocity.z = movement_input.y * (SPEED * 2)
	elif move_type == "charge":
		velocity.x = movement_input.x * (SPEED * 2.6)
		velocity.z = movement_input.y * (SPEED * 2.6)
	else:
		velocity.x = movement_input.x * SPEED
		velocity.z = movement_input.y * SPEED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	movement_input = Input.get_vector("left", "right", "up", "down")


	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	state_machine.dispatch("to_idle")
