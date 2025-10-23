extends CharacterBody3D

@export var speed_initial: float = 20.0
@export var speed_max: float = 130.0
@export var acceleration: float = 4.0
@export var lateral_speed: float = 10.0
@export var base_tremble: float = 0.1
@export var max_tremble: float = 0.3
@export var base_turn_speed: float = 5.0
@export var max_turn_speed: float = 10.0
@export var drift_angle: float = 25.0

var current_speed: float = 20.0
var current_tilt: float = 0.0
@onready var car_mesh = $CarMesh
@onready var ruedas = [$"CarMesh/wheel-back-right", $"CarMesh/wheel-front-right", $"CarMesh/wheel-front-left", $"CarMesh/wheel-back-left"]

func _ready():
	position = Vector3(0, 1.0, 0)
	floor_snap_length = 2.0
	motion_mode = MOTION_MODE_GROUNDED

func _physics_process(delta):
	
	# Avance del auto
	current_speed = min(current_speed + acceleration * delta, speed_max)
	velocity.z = current_speed
	
	# Gira las ruedas, simula animación
	for rueda in ruedas:
		rueda.rotation.x += current_speed * delta

	var speed_ratio = (current_speed - speed_initial) / (speed_max - speed_initial)
	var drunk_tremble = lerp(base_tremble, max_tremble, speed_ratio)
	var turn_speed = lerp(base_turn_speed, max_turn_speed, speed_ratio)
	
	# Simula derrapes cortos
	var lateral_input = Input.get_axis("ui_left", "ui_right")
	velocity.x = lateral_input * lateral_speed + randf_range(-drunk_tremble, drunk_tremble)
	position.x = clamp(position.x, -6.0, 6.0)

	move_and_slide()
	
	# Tilt lateral del auto al doblar
	var target_tilt = lateral_input * drift_angle
	current_tilt = lerp(current_tilt, target_tilt, turn_speed * delta)
	car_mesh.rotation_degrees.y = current_tilt
	car_mesh.rotation_degrees.z = sin(Time.get_ticks_msec() * 0.01) * drunk_tremble * 10.0
