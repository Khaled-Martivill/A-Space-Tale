extends CanvasLayer

signal completed(win: bool)

@export var empty_bag: Sprite2D
@export var full_syringe: Sprite2D
@export var empty_syringe: Sprite2D
@export var product_bag_s: Sprite2D
@export var incubator_time = 10.0

@onready var bag = $Node2D/Drag/Bag
@onready var syringe = $Node2D/Drag/Syringe
@onready var product_bag = $Node2D/Drag/Product_Bag

@onready var bag_slot = $Node2D/Function/Bag
@onready var prod_bag = $Node2D/Function/ProductionBag

var finished = false
var syringe_full = false
var bag_stage = 0
var stage = 0

@export var shake_reversals_needed := 14
@export var shake_min_speed := 900.0
@export var shake_brightness := 1.5

func _ready():
	product_bag_s.hide()
	product_bag.lock()
	
	bag.placed.connect(_on_placed_bag)
	syringe.placed.connect(_on_placed_syringe)
	product_bag.placed.connect(_on_placed_prod_bag)

func _on_placed_bag(slot: Node2D):
	empty_bag.hide()
	bag_slot.set_active(true)
	bag_slot.set_visible_slot(true)

func _on_placed_syringe(slot: Node2D):
	if slot == bag_slot and not syringe_full:
		_extract_water()
	elif slot == prod_bag and syringe_full:
		_deliver_water()

func _extract_water():
	syringe_full = true
	empty_syringe.hide()
	full_syringe.show()
	empty_bag.show()
	bag_slot.set_active(false)
	bag_slot.set_visible_slot(false)
	prod_bag.set_active(true)
	prod_bag.set_visible_slot(true)
	syringe.unlock()

func _deliver_water():
	syringe_full = false
	full_syringe.hide()
	empty_syringe.show()
	
	prod_bag.set_active(false)
	prod_bag.set_visible_slot(false)
	
	product_bag_s.show()
	await  _shake(product_bag)
	if finished:
		return
	product_bag.unlock()
	product_bag.draggable = shake_hover
	
func _on_placed_prod_bag(slot: Node2D):
	if slot.id == 4:
		product_bag_s.hide()
		product_bag.lock()
		_finish(true)
		product_bag_s.hide()
	else:
		product_bag_s.hide()
		if bag_stage == 0:
			bag_stage = 1
			print("Incubando...")
			await get_tree().create_timer(incubator_time).timeout
			if finished:
				return
	
	product_bag.modulate = Color.WHITE
	product_bag.id = 4
	product_bag.unlock()
	product_bag_s.show()


func _shake(piece: Node2D) -> void:
	var area: Area2D = piece.get_node("Area2D")
	shake_hover = false
	area.mouse_entered.connect(_on_shake_mouse_entered)
	area.mouse_exited.connect(_on_shake_mouse_exited)
	var origin := piece.position
	var count := 0
	var last_x := 0.0
	var last_dir := 0.0
	var idle := 0.0
	var grabbed := false
	var was_pressed := Input.is_action_pressed("Click")

	while count < shake_reversals_needed and not finished:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		var mx := get_viewport().get_mouse_position().x
		var pressed := Input.is_action_pressed("Click")

		if pressed and not was_pressed:
			if shake_hover:
				grabbed = true
				last_x = mx
				last_dir = 0.0
		elif not pressed:
			grabbed = false
		was_pressed = pressed
		Dragging.is_dragging = grabbed

		if not grabbed:
			piece.position = origin
			piece.rotation_degrees = 0.0
			continue

		var vx := (mx - last_x) / maxf(dt, 0.0001)
		last_x = mx

		if absf(vx) > shake_min_speed:
			var dir := signf(vx)
			if last_dir != 0.0 and dir != last_dir:
				count += 1
			last_dir = dir
			idle = 0.0
		else:
			idle += dt
			if idle > 0.5:
				count = maxi(count - 1, 0)
				idle = 0.0
				last_dir = 0.0

		piece.position = origin + Vector2(clampf(vx * 0.02, -30.0, 30.0), 0.0)
		piece.rotation_degrees = clampf(vx * 0.01, -10.0, 10.0)

	area.mouse_entered.disconnect(_on_shake_mouse_entered)
	area.mouse_exited.disconnect(_on_shake_mouse_exited)
	Dragging.is_dragging = false
	create_tween().tween_property(piece, "modulate", Color(shake_brightness, shake_brightness, shake_brightness), 0.3)
	
# ¿El mouse está sobre el Area2D de la pieza?
func _hovering(piece: Node2D) -> bool:
	var area: Area2D = piece.get_node("Area2D")
	var q := PhysicsPointQueryParameters2D.new()
	q.position = piece.get_global_mouse_position()
	q.collide_with_areas = true
	q.collide_with_bodies = false
	for hit in piece.get_world_2d().direct_space_state.intersect_point(q):
		if hit.collider == area:
			return true
	return false

var shake_hover := false

func _on_shake_mouse_entered() -> void:
	shake_hover = true

func _on_shake_mouse_exited() -> void:
	shake_hover = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_finish(false)

func _finish(win: bool) -> void:
	if finished:
		return
	finished = true
	Dragging.is_dragging = false
	completed.emit(win)
