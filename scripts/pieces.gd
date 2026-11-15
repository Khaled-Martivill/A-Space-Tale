extends Node2D

signal placed(slot : Node2D)

@export var id := 0
@export var return_to_start = false
@export var lock_on_place = true

var draggable := false
var dragging := false
var is_inside_dropable := false
var locked := false
var body_ref: Node2D
var offset: Vector2
var initialPos: Vector2

func _ready() -> void:
	var area: Area2D = $Area2D
	area.input_pickable = true
	if not area.mouse_entered.is_connected(_on_area_2d_mouse_entered):
		area.mouse_entered.connect(_on_area_2d_mouse_entered)
	if not area.mouse_exited.is_connected(_on_area_2d_mouse_exited):
		area.mouse_exited.connect(_on_area_2d_mouse_exited)
	if not area.body_entered.is_connected(_on_area_2d_body_entered):
		area.body_entered.connect(_on_area_2d_body_entered)
	if not area.body_exited.is_connected(_on_area_2d_body_exited):
		area.body_exited.connect(_on_area_2d_body_exited)

func _process(_delta: float) -> void:
	if locked or not draggable:
		return

	if Input.is_action_just_pressed("Click"):
		initialPos = global_position
		offset = get_global_mouse_position() - global_position
		dragging = true
		Dragging.is_dragging = true
		z_index = 10

	if not dragging:
		return

	if Input.is_action_pressed("Click"):
		global_position = get_global_mouse_position() - offset
	elif Input.is_action_just_released("Click"):
		dragging = false
		Dragging.is_dragging = false
		draggable = false
		scale = Vector2(1.3, 1.3)
		z_index = 0
		var tween = create_tween()
		if is_inside_dropable:
			locked = true
			var slot: Node2D = body_ref
			var target: Vector2 = initialPos if return_to_start else slot.global_position
			is_inside_dropable = false
			body_ref = null
			tween.tween_property(self, "global_position", target, 0.2).set_ease(Tween.EASE_OUT)
			tween.finished.connect(func():
				locked = lock_on_place
				placed.emit(slot)
			)
		else:
			tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_entered() -> void:
	if not locked and not Dragging.is_dragging:
		draggable = true
		scale = Vector2(1.33, 1.33)

func _on_area_2d_mouse_exited() -> void:
	if not locked and not Dragging.is_dragging:
		draggable = false
		scale = Vector2(1.3, 1.3)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not locked and body.is_in_group("dropable") and body.id == id:
		is_inside_dropable = true
		body.modulate = Color.WHITE
		body_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if not locked and body.is_in_group("dropable") and body.id == id:
		is_inside_dropable = false
		body.modulate = Color.DARK_GRAY

func lock():
	locked = true
	draggable = false
	scale= Vector2.ONE

func unlock():
	locked = false
	is_inside_dropable = false
	body_ref = null
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("dropable") and body.id == id:
			is_inside_dropable = true
			body_ref = body
