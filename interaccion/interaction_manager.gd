extends Node2D

@onready var label = $Label

const BASE_TEXT = "[C] to interact"
const OFFSET = Vector2(0,-30)

var player: Node2D
var active_areas = []
var can_interact = true

func register_area(area: InteractionArea):
	if area not in active_areas:
		active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	active_areas.erase(area)
		
func _process(delta):
	if not is_instance_valid(player):
		player = _find_local_player()
		
	if player and active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		var cercana: InteractionArea = active_areas[0]
		label.text = BASE_TEXT + cercana.action_name
		label.global_position = cercana.global_position + OFFSET - Vector2(label.size.x / 2.0, 0)
		label.show()
	else:
		label.hide()
		

func _find_local_player() -> Node2D:
	for p in get_tree().get_nodes_in_group("player"):
		if p.is_multiplayer_authority():
			return p
	return null

func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player

func _input(event):
	if event.is_action_pressed("Interaccion") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			await active_areas[0].interact.call()
			
			can_interact = true
