extends CharacterBody3D

# --- Parámetros de movimiento ---
@export var speed_initial: float = 20.0
@export var speed_max: float = 40.0
@export var acceleration: float = 2.0
@export var lateral_speed: float = 10.0
@export var gravity: float = 25.0

# --- Efectos visuales ---
@export var base_tremble: float = 0.1
@export var max_tremble: float = 0.3
@export var base_turn_speed: float = 5.0
@export var max_turn_speed: float = 10.0
@export var drift_angle: float = 25.0
@export var drift_tilt: float = 10.0

# --- Salto y giro ---
@export var jump_force: float = 14.0
@export var spin_speed: float = 720.0 # grados por segundo

# --- Variables internas ---
var current_speed: float = 20.0
var current_drift: float = 0.0
var is_jumping: bool = false
var spin_axis: String = ""
var spin_rate: float = 0.0
var spin_progress: float = 0.0

# --- Referencias ---
@onready var car_mesh = $CarMesh
@onready var wheels = [$"CarMesh/wheel-front-right", $"CarMesh/wheel-front-left", $"CarMesh/wheel-back-right", $"CarMesh/wheel-back-left"]

func _ready():
	position = Vector3(0, 1.0, 0)
	floor_snap_length = 2.0
	motion_mode = MOTION_MODE_GROUNDED


func _physics_process(delta):

	# --- Movimiento hacia adelante ---
	current_speed = min(current_speed + acceleration * delta, speed_max)
	velocity.z = current_speed

	# --- Movimiento lateral con temblor ---
	var speed_ratio = (current_speed - speed_initial) / (speed_max - speed_initial)
	var drunk_tremble = lerp(base_tremble, max_tremble, speed_ratio)
	var turn_speed = lerp(base_turn_speed, max_turn_speed, speed_ratio)
	var lateral_input = Input.get_axis("ui_left", "ui_right")
	velocity.x = lateral_input * lateral_speed + randf_range(-drunk_tremble, drunk_tremble)
	position.x = clamp(position.x, -6.0, 6.0)

	# --- Aplicar gravedad ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# --- Salto ---
	if Input.is_action_just_pressed("salto") and is_on_floor():
		print("Salto detectado!") # Debug
		velocity.y = jump_force
		is_jumping = true
		spin_progress = 0.0
		var axis = ""
		if randi() % 2 == 0: 
			"y" 
		else: 
			"z"
		spin_axis = axis
		
		spin_rate = randf_range(360.0, spin_speed)

	# --- Movimiento con colisiones ---
	move_and_slide()

	# --- Rotación durante salto ---
	if is_jumping and not is_on_floor():
		spin_progress += spin_rate * delta
		if spin_axis == "y":
			car_mesh.rotation_degrees.y = spin_progress
		else:
			car_mesh.rotation_degrees.z = spin_progress

	# --- Reset suave al aterrizar ---
	if is_on_floor() and is_jumping:
		is_jumping = false
		spin_progress = 0.0
		car_mesh.rotation_degrees = Vector3(0, 0, 0)

	# --- Derrape visual (efecto al girar) ---
	var target_drift = lateral_input * drift_angle
	current_drift = lerp(current_drift, target_drift, turn_speed * delta)
	car_mesh.rotation_degrees.y += current_drift * delta
	car_mesh.rotation_degrees.z += -lateral_input * drift_tilt + sin(Time.get_ticks_msec() * 0.01) * drunk_tremble * 10.0

	# --- Rotación de ruedas ---
	for wheel in wheels:
		wheel.rotation.x += current_speed * delta * 5.0


#func is_on_floor_custom() -> bool:
	#var world = get_world_3d()
	#if world == null:
		#return false
	#var space_state = world.direct_space_state
	#if space_state == null:
		#return false
#
	#var ray = PhysicsRayQueryParameters3D.new()
	#ray.from = global_transform.origin + Vector3(0, 0.5, 0)
	#ray.to = global_transform.origin + Vector3(0, -1.5, 0)
	#ray.exclude = [self]
	#ray.collide_with_areas = false
#
	#var collision = space_state.intersect_ray(ray)
	#return collision.size() > 0
