extends StaticBody2D

@export var id = 0

func _ready():
	add_to_group("dropable")
	modulate = Color.DARK_GRAY

func _process(_delta):
	if Dragging.is_dragging:
		visible = true
	else:
		visible = false
