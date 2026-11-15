extends Node

func _ready() -> void:
	# Inicia un temporizador de 10 segundos y espera a que termine
	await get_tree().create_timer(10.0).timeout
	
	# Cambia a la nueva escena (asegúrate de poner tu ruta real)
	get_tree().change_scene_to_file("res://scenes/world.tscn")
