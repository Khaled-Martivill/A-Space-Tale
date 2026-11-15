extends Node2D

enum Status { FREE, BUSY, COMPLETED }

@export var minigame_scene: PackedScene

@onready var interaction_area: InteractionArea = $InteractionArea

signal start_response(allowed: bool)

# Esta variable se sincroniza con el MultiplayerSynchronizer
var status: Status = Status.FREE:
	set(v):
		status = v
		if is_node_ready():
			_update_visual()

var occupant := 0   # ID del jugador que está jugando (solo lo usa el servidor)

func _ready() -> void:
	interaction_area.action_name = ""
	interaction_area.interact = _on_interact
	_update_visual()
	if multiplayer.is_server():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _update_visual() -> void:
	interaction_area.enabled = (status == Status.FREE)
	match status:
		Status.FREE:
			$Sprite2D.modulate = Color.YELLOW
		Status.BUSY:
			$Sprite2D.modulate = Color.WHITE
		Status.COMPLETED:
			$Sprite2D.modulate = Color.GRAY

# ---------- Lado del jugador que interactúa ----------
func _on_interact() -> void:
	if minigame_scene == null:
		push_warning("Falta asignar minigame_scene en " + name)
		return

	request_start.rpc_id(1)
	var allowed: bool = await start_response
	if not allowed:
		return

	var player = InteractionManager.player
	player.can_move = false

	var game = minigame_scene.instantiate()
	get_tree().current_scene.add_child(game)

	var win: bool = await game.completed
	game.queue_free()
	player.can_move = true

	request_end.rpc_id(1, win)

# ---------- Lado del servidor ----------
@rpc("any_peer", "call_local", "reliable")
func request_start() -> void:
	if not multiplayer.is_server():
		return
	var who := multiplayer.get_remote_sender_id()
	if who == 0:
		who = multiplayer.get_unique_id()

	var ok := (status == Status.FREE)
	if ok:
		status = Status.BUSY
		occupant = who
	reply_start.rpc_id(who, ok)

@rpc("any_peer", "call_local", "reliable")
func request_end(win: bool) -> void:
	if not multiplayer.is_server():
		return
	var who := multiplayer.get_remote_sender_id()
	if who == 0:
		who = multiplayer.get_unique_id()

	if status != Status.BUSY or who != occupant:
		return
	occupant = 0
	status = Status.COMPLETED if win else Status.FREE

func _on_peer_disconnected(id: int) -> void:
	if status == Status.BUSY and id == occupant:
		occupant = 0
		status = Status.FREE

@rpc("authority", "call_local", "reliable")
func reply_start(allowed: bool) -> void:
	start_response.emit.call_deferred(allowed)
