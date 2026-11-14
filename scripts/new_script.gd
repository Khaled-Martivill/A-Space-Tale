extends CharacterBody2D

@onready var animacion: AnimationPlayer = $AnimationPlayer
@onready var rayo: RayCast2D = $RayCast2D

var velocidad = 100.0

func _physics_process(delta):
	var direccion = Vector2.ZERO

	if Input.is_action_pressed("Derecha"):
		direccion.x += 1
	if Input.is_action_pressed("Izquierda"):
		direccion.x -= 1
	if Input.is_action_pressed("Abajo"):
		direccion.y += 1
	if Input.is_action_pressed("Arriba"):
		direccion.y -= 1
