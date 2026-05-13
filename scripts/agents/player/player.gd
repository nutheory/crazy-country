extends CharacterBody3D

@export var state_machine: LimboHSM 

@onready var idle_state = $LimboHSM/Idle
@onready var walk_state = $LimboHSM/Walk
@onready var turn_state = $LimboHSM/Turn

@onready var sprite = $Sprite3D

const SPEED = 5.0
const JUMP_VELOCITY = 8

var movement_input: Vector2 = Vector2.ZERO
var current_direction: String = "right" 

func _ready():
	_initialize_state_machine()
	
func _initialize_state_machine() -> void:
	state_machine.add_transition(idle_state, turn_state, &"dir_changed")
	state_machine.add_transition(walk_state, turn_state, &"dir_changed")
	
	state_machine.add_transition(turn_state, walk_state, &"turn_done")
	state_machine.add_transition(turn_state, idle_state, &"turn_to_idle")
	
	# Setup State Machine
	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)
	
func wants_to_turn() -> bool:
	if movement_input.x > 0 and current_direction == "left":
		return true
	if movement_input.x < 0 and current_direction == "right":
		return true
	return false
	
func apply_movement(delta) -> void:
	velocity.x = movement_input.x * SPEED
	velocity.z = movement_input.y * SPEED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	movement_input = Input.get_vector("left", "right", "up", "down")


	move_and_slide()
