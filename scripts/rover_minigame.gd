extends CanvasLayer

signal completed(win: bool)

@onready var pieces: Array = $Pieces.get_children()

var placed_count := 0
var finished := false

func _ready() -> void:
	for p in pieces:
		p.placed.connect(_on_piece_placed)

func _on_piece_placed(_slot: Node2D) -> void:
	placed_count += 1
	if placed_count >= pieces.size():
		await get_tree().create_timer(0.6).timeout
		_finish(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_finish(false)

func _finish(win: bool) -> void:
	if finished:
		return
	finished = true
	Dragging.is_dragging = false
	completed.emit(win)
