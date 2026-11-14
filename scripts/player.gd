extends CharacterBody2D

const SPEED := 220.0

func _enter_tree() -> void:
set_multiplayer_authority(name.to_int())

func _ready() -> void:
$Camera2D.enabled = is_multiplayer_authority()

func _physics_process(_delta: float) -> void:
if not is_multiplayer_authority():
return
var dir := Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
velocity = dir * SPEED
move_and_slide()
