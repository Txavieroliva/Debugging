extends CharacterBody3D

# --- Movimiento ---
@export var speed_initial: float = 20.0
@export var speed_max: float = 40.0
@export var acceleration: float = 2.0
@export var lateral_speed: float = 10.0
@export var gravity: float = 25.0

# --- Efectos ---
@export var base_tremble: float = 0.1
@export var max_tremble: float = 0.3
@export var turn_speed_base: float = 5.0
@export var turn_speed_max: float = 10.0
@export var drift_angle: float = 25.0
@export var drift_tilt: float = 10.0

# --- Salto ---
@export var jump_force: float = 14.0

# --- Variables ---
var current_speed: float = 20.0
var current_drift: float = 0.0

# --- Referencias ---
@onready var car_mesh = $CarMesh
@onready var wheels = [$"CarMesh/wheel-front-right", $"CarMesh/wheel-front-left", $"CarMesh/wheel-back-right", $"CarMesh/wheel-back-left"]

func _ready():
	position = Vector3(0, 1.0, 0)
	floor_snap_length = 2.0
	motion_mode = MOTION_MODE_GROUNDED

func _physics_process(delta):
	# --- Velocidad ---
	current_speed = min(current_speed + acceleration * delta, speed_max)
	velocity.z = current_speed

	# --- Movimiento lateral ---
	var speed_ratio = (current_speed - speed_initial) / (speed_max - speed_initial)
	var tremble = lerp(base_tremble, max_tremble, speed_ratio)
	var turn_speed = lerp(turn_speed_base, turn_speed_max, speed_ratio)
	var lateral_input = Input.get_axis("ui_left", "ui_right")
	velocity.x = lateral_input * lateral_speed + randf_range(-tremble, tremble)
	position.x = clamp(position.x, -6.0, 6.0)

	# --- Gravedad ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# --- Salto simple ---
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = jump_force

	# --- Física ---
	move_and_slide()

	# --- Derrape visual ---
	var target_drift = lateral_input * drift_angle
	current_drift = lerp(current_drift, target_drift, turn_speed * delta)
	car_mesh.rotation_degrees.y = current_drift
	car_mesh.rotation_degrees.z = -lateral_input * drift_tilt + sin(Time.get_ticks_msec() * 0.01) * tremble * 10.0

	# --- Ruedas ---
	for wheel in wheels:
		wheel.rotation.x += current_speed * delta * 5.0
