extends StaticBody2D

@export var id = 0
@export var active = true
@export var visible_slot = true

func _ready():
	add_to_group("dropable")
	set_active(active)
	set_visible(visible_slot)

func set_active(value: bool):
	active = value
	for c in get_children():
		if c is CollisionShape2D:
			c.set_deferred("disabled", not value)

func set_visible_slot(value: bool):
	visible = value
	for c in get_children():
		if c is CollisionShape2D:
			c.set_deferred("disabled", not value)

func _process(_delta):
	if Dragging.is_dragging:
		modulate = Color.YELLOW
	else:
		modulate = Color.WHITE
