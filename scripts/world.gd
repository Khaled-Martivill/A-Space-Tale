extends Node2D

func _ready() -> void:
	if not multiplayer.is_server():
		Network.request_spawn.rpc_id(1)
