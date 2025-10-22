extends Node3D

@export var tiles: Array[PackedScene] = []
@export var offset: float = 19.0  # Longitud de tile (ajustado a tu sugerencia)
@export var spawn_ahead: int = 20  # Tiles por grupo inicial
@export var spawn_group_size: int = 20  # Tiles por trigger (de a 5)
@export var spawn_threshold: float = 600.0  # Buffer para spawnear antes (offset * spawn_group_size * 1.5)
@export var delete_distance: float = 100.0  # Distancia atrás para borrar

var rng = RandomNumberGenerator.new()
var last_spawn_z: float = 0.0
var player: VehicleBody3D

func _ready() -> void:
	player = get_parent().get_node("Jugador")
	rng.randomize()
	if tiles.is_empty():
		push_error("No tiles assigned!")
		return
	# Spawnea 2 grupos iniciales para cubrir más distancia
	spawn_group()

func _process(delta: float):
	if player == null:
		return
	var player_z = player.global_position.z
	# Spawnea grupo si jugador se acerca
	if player_z > last_spawn_z - spawn_threshold:
		spawn_group()
	# Borra tiles viejos
	for child in get_children():
		if child is Node3D and child.position.z < player_z - delete_distance:
			child.queue_free()
			print("Borrado tile viejo en Z=", child.position.z)

func spawn_group():
	for i in spawn_group_size:
		var pos_z = last_spawn_z + offset
		spawn_single_tile(pos_z)
	print("Spawneado grupo de ", spawn_group_size, " tiles desde Z=", last_spawn_z - (spawn_group_size - 1) * offset)

func spawn_single_tile(pos_z: float):
	var num = rng.randi_range(0, tiles.size() - 1)
	var instancia = tiles[num].instantiate()
	instancia.position.z = pos_z - 0.05  # Overlap para evitar gaps/saltos
	add_child(instancia)
	last_spawn_z = pos_z + offset
