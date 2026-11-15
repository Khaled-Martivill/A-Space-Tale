extends Area2D
class_name InteractionArea

@export var action_name: String = "Interactuar"

var interact: Callable = func(): pass

var p_in := false

var enabled := true:
	set(v):
		enabled = v
		if p_in:
			if enabled:
				InteractionManager.register_area(self)
			else:
				InteractionManager.unregister_area(self)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_multiplayer_authority():
		p_in = true
		if enabled:
			InteractionManager.register_area(self)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player") and body.is_multiplayer_authority():
		p_in = false
		InteractionManager.unregister_area(self)

func _exit_tree():
	InteractionManager.unregister_area(self)
