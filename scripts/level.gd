extends Node

var minigames_completed: int = 0
var total_minigames: int = 2

func _ready() -> void:
	# Conectar la señal de todas las estaciones en el nivel
	var stations = get_tree().get_nodes_in_group("minigame_stations")
	for station in stations:
		station.station_completed.connect(_on_station_completed)

func _on_station_completed() -> void:
	# Solo el servidor administra el progreso global
	if not multiplayer.is_server():
		return
		
	minigames_completed += 1
	print("Minijuegos completados: ", minigames_completed, "/", total_minigames)
	
	if minigames_completed >= total_minigames:
		# Ordenar a todos los clientes que cambien de escena
		change_scene_for_all.rpc("res://scenes/main_menu.tscn")

# Este RPC asegura que tanto el servidor como los clientes cambien de nivel al mismo tiempo
@rpc("authority", "call_local", "reliable")
func change_scene_for_all(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
