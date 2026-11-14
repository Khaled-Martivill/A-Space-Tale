extends CharacterBody2D

@export var velocidad = 100.0

func _physics_process(delta):
	var direccion = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	velocity = direccion * velocidad
	move_and_slide()
