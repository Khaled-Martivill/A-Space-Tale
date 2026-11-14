extends Node2D

func _ready() -> void:
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		Network.request_spawn()
	elif not multiplayer.is_server():
		Network.request_spawn.rpc_id(1)
