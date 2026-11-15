extends Node

var money: int = 200000
var current_shuttle_frames: SpriteFrames = load("res://rocket_builder/shuttle_base.tres")

# Guarda qué opción está equipada en cada ranura (vacío al inicio)
var equipped_parts := {
	"nose": {},
	"cabin": {},
	"tank": {},
	"engine": {}
}

# Totales acumulados listos para tus ecuaciones físicas
var build_data := {
	"dry_mass": 0.0,
	"fuel_mass": 0.0,
	"thrust": 0.0,
	"isp": 0.0,
	"drag_factor": 0.0
}

func recalculate_build_data() -> void:
	build_data = {
		"dry_mass": 0.0,
		"fuel_mass": 0.0,
		"thrust": 0.0,
		"isp": 0.0,
		"drag_factor": 0.0
	}
	
	for slot_key in ["nose", "cabin", "tank", "engine"]:
		var part: Dictionary = equipped_parts[slot_key]
		if part.is_empty():
			continue
		build_data["dry_mass"] += part.get("dry_mass", 0.0)
		build_data["fuel_mass"] += part.get("fuel_mass", 0.0)
		build_data["thrust"] += part.get("thrust", 0.0)
		build_data["isp"] += part.get("isp", 0.0)
		build_data["drag_factor"] += part.get("drag_factor", 0.0)
		
var launch_success: bool = false
var launch_report: String = ""
