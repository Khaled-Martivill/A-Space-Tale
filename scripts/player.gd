extends CharacterBody2D
@onready var sprite: Sprite2D = $Sprite2D

const SPEED := 120.0

func _enter_tree() -> void:
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())

func _ready() -> void:
	$Camera2D.enabled = is_multiplayer_authority()

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	var dir := Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	velocity = dir * SPEED
	
	if dir != Vector2.ZERO:
		

		var tiempo := Time.get_ticks_msec() * 0.001
		var saltito_freq := 20.0
		var saltito_altura := 3.0
		sprite.position.y = -abs(sin(tiempo * saltito_freq)) * saltito_altura
		sprite.rotation = sin(tiempo * saltito_freq) * 0.15

		if dir.x != 0:
			sprite.flip_h = dir.x < 0
	else:
		sprite.position.y = move_toward(sprite.position.y, 0.0, 2.0)
		sprite.rotation = move_toward(sprite.rotation, 0.0, 0.05)

	move_and_slide()
