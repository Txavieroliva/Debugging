extends Node3D

# --- Configuración ---
@export var obstacles: Array[PackedScene] = []
@export var offset: float = 20.0
@export var spawn_ahead: int = 15
@export var spawn_group_size: int = 10
@export var spawn_threshold: float = 400.0
@export var delete_distance: float = 100.0
@export var lane_width: float = 6.0

# --- Variables internas ---
var rng = RandomNumberGenerator.new()
var last_spawn_z: float = 0.0
var player: CharacterBody3D
@export var obstacles_container: Node3D # Ruta absoluta

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Jugador no encontrado. Añade al grupo 'player'.")
		return
	
	if not obstacles_container:
		push_error("No se encontró 'Main/Obstacles'. Crea un Node3D con ese nombre.")
		return
	
	rng.randomize()
	if obstacles.is_empty():
		push_error("No hay obstáculos asignados!")
		return
	
	# Spawnear grupo inicial
	for i in spawn_ahead:
		var pos_z = player.global_position.z + (i + 1) * offset
		spawn_single_obstacle(pos_z)
	last_spawn_z = player.global_position.z + spawn_ahead * offset

func _process(_delta):
	if not player or not obstacles_container: return
	
	var player_z = player.global_position.z
	
	# Spawnear grupo
	if player_z > last_spawn_z - spawn_threshold:
		spawn_group()
	
	# Eliminar viejos
	_clean_old_obstacles()

func spawn_group():
	for i in spawn_group_size:
		var pos_z = last_spawn_z + offset
		spawn_single_obstacle(pos_z)
	print("Grupo de ", spawn_group_size, " obstáculos spawneados desde Z=", last_spawn_z)

func spawn_single_obstacle(pos_z: float):
	if obstacles.is_empty(): return
	
	# Elegir obstáculo
	var num = rng.randi_range(0, obstacles.size() - 1)
	var instancia = obstacles[num].instantiate()
	
	# Elegir carril
	var lane = rng.randi_range(-1, 1)
	var x_pos = lane * (lane_width / 2)
	
	# Posicionar
	instancia.position = Vector3(x_pos, 0.5, pos_z - 0.05)
	instancia.add_to_group("obstacle")
	obstacles_container.add_child(instancia)  # Usa @onready
	
	last_spawn_z = pos_z + offset

func _clean_old_obstacles():
	var player_z = player.global_position.z
	for child in get_tree().get_nodes_in_group("obstacle"):
		if child.global_position.z < player_z - delete_distance:
			child.queue_free()
