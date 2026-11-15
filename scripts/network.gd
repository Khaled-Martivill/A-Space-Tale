extends Node

const DEFAULT_PORT := 7777
const DEFAULT_IP := "100.106.142.83"
const PLAYER_SCENE := preload("res://scenes/player.tscn")
const WORLD_SCENE_PATH := "res://scenes/world.tscn"
const ROCKET_BUILDER_SCENE_PATH := "res://rocket_builder/rocket_builder.tscn"

signal connection_failed_msg(reason: String)

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var port := DEFAULT_PORT
	var connect_ip := ""

	for arg in args:
		if arg.begins_with("--port="):
			port = arg.split("=")[1].to_int()
		elif arg.begins_with("--connect="):
			connect_ip = arg.split("=")[1]

	if "--server" in args:
		start_server(port)
	elif "--local" in args:
		start_local()
	elif connect_ip != "":
		join_server(connect_ip, port)

func start_local() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().change_scene_to_file.call_deferred(ROCKET_BUILDER_SCENE_PATH)

func start_server(port: int = DEFAULT_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 16)
	if err != OK:
		push_error("[SERVER] Error puerto %d: %s" % [port, error_string(err)])
		get_tree().quit(1)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(func(id: int): print("[SERVER] Conectado: ", id))
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("[SERVER] Escuchando en 0.0.0.0:%d/udp" % port)
	get_tree().change_scene_to_file.call_deferred(WORLD_SCENE_PATH)

func join_server(ip: String, port: int = DEFAULT_PORT) -> void:
	var target_ip := ip.strip_edges()
	if target_ip == "":
		target_ip = DEFAULT_IP

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(target_ip, port)
	if err != OK:
		connection_failed_msg.emit("Error cliente: " + error_string(err))
		return

	multiplayer.multiplayer_peer = peer
	if not multiplayer.connected_to_server.is_connected(_on_connected_ok):
		multiplayer.connected_to_server.connect(_on_connected_ok, CONNECT_ONE_SHOT)
	if not multiplayer.connection_failed.is_connected(_on_connected_fail):
		multiplayer.connection_failed.connect(_on_connected_fail, CONNECT_ONE_SHOT)
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected, CONNECT_ONE_SHOT)

func _on_connected_ok() -> void:
	get_tree().change_scene_to_file(WORLD_SCENE_PATH)

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null
	connection_failed_msg.emit("Fallo de conexion (revisa IP/puerto).")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

@rpc("any_peer", "call_local", "reliable")
func request_spawn() -> void:
	if not multiplayer.is_server():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()
	var container := get_tree().current_scene.get_node_or_null("Players")
	if container == null or container.has_node(str(sender_id)):
		return

	var player := PLAYER_SCENE.instantiate()
	player.name = str(sender_id)
	player.position = Vector2(randf_range(100, 400), randf_range(100, 300))
	container.add_child(player, true)
	if not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
		print("[SERVER] Jugador instanciado: ", sender_id)

func _on_peer_disconnected(id: int) -> void:
	print("[SERVER] Desconectado: ", id)
	var container := get_tree().current_scene.get_node_or_null("Players")
	if container and container.has_node(str(id)):
		container.get_node(str(id)).queue_free()
