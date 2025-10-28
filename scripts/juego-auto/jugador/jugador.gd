extends CharacterBody3D

@export var speed_initial: float = 20.0
@export var speed_max: float = 40.0
@export var acceleration: float = 2.0
@export var lateral_speed: float = 10.0
@export var base_tremble: float = 0.1
@export var max_tremble: float = 0.3
@export var base_turn_speed: float = 5.0
@export var max_turn_speed: float = 10.0
@export var drift_angle: float = 25.0
@export var drift_tilt: float = 10.0
@export var jump_force: float = 10.0
@export var spin_speed: float = 720.0  # Grados por segundo

var current_speed: float = 20.0
var current_drift: float = 0.0
var is_jumping: bool = false
var spin_axis: String = ""  # "y" o "z"
var spin_rate: float = 0.0
@onready var car_mesh = $CarMesh
@onready var wheels = [$"CarMesh/wheel-front-left", $"CarMesh/wheel-front-right", $"CarMesh/wheel-back-left", $"CarMesh/wheel-back-right"]

func _ready():
	position = Vector3(0, 1.0, 0)
	floor_snap_length = 2.0
	motion_mode = MOTION_MODE_GROUNDED

func _physics_process(delta):
	current_speed = min(current_speed + acceleration * delta, speed_max)
	velocity.z = current_speed

	var speed_ratio = (current_speed - speed_initial) / (speed_max - speed_initial)
	var drunk_tremble = lerp(base_tremble, max_tremble, speed_ratio)
	var turn_speed = lerp(base_turn_speed, max_turn_speed, speed_ratio)

	var lateral_input = Input.get_axis("ui_left", "ui_right")
	velocity.x = lateral_input * lateral_speed + randf_range(-drunk_tremble, drunk_tremble)
	position.x = clamp(position.x, -6.0, 6.0)

	# Salto con pirueta
	if Input.is_action_just_pressed("salto") and is_on_floor():
		print("SALTA PUTO")
		velocity.y = jump_force
		is_jumping = true
		spin_axis = "y" if randi() % 2 == 0 else "z"
		spin_rate = randf_range(360.0, spin_speed)

	# Aplicar rotación durante salto
	if is_jumping and not is_on_floor():
		if spin_axis == "y":
			car_mesh.rotate_y(deg_to_rad(spin_rate * delta))
		else:
			car_mesh.rotate_z(deg_to_rad(spin_rate * delta))

	# Reset al tocar suelo
	if is_on_floor() and is_jumping:
		is_jumping = false
		car_mesh.rotation = Vector3(0, 0, 0)  # Mirando al frente

	move_and_slide()

	# Derrape
	var target_drift = lateral_input * drift_angle
	current_drift = lerp(current_drift, target_drift, turn_speed * delta)
	car_mesh.rotation_degrees.y = current_drift
	car_mesh.rotation_degrees.z = -lateral_input * drift_tilt + sin(Time.get_ticks_msec() * 0.01) * drunk_tremble * 10.0
	# Ruedas
	for wheel in wheels:
		wheel.rotation.x += current_speed * delta * 5.0
