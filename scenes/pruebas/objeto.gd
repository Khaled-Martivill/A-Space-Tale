extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.action_name = "abrir"
	interaction_area.interact = _on_interact

func _on_interact() -> void:
	print("¡Interacción funcionando!")
	$Sprite2D.modulate = Color(randf(), randf(), randf())
