extends VehicleBody3D

@export var speed: float = 60.0

func _ready():
	linear_damp = 0.5  # Amortiguación lineal
	angular_damp = 0.5  # Amortiguación angular
	contact_monitor = true  # Para detectar colisiones si necesitas

func _physics_process(delta):
	linear_velocity.z = speed  # Avance constante en +Z
