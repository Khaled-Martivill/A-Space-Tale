extends Control

@onready var item_preview: TextureRect = $MainLayout/UIPanel/ItemPreview
@onready var money_label: Label = $MainLayout/UIPanel/MoneyLabel
@onready var info_label: Label = $MainLayout/UIPanel/InfoLabel
@onready var parts_list: VBoxContainer = $MainLayout/UIPanel/PartsScroll/PartsList
@onready var shuttle_anim: AnimatedSprite2D = $MainLayout/HangarArea/ShuttleAnim

# Catálogo estructurado por las 4 partes del cohete con sus variables físicas
const PARTS_DATA := {
	"nose": {
		"category_title": "1. PUNTA / NARIZ (Aerodinámica)",
		"options": {
			"nose_1": {
				"name": "Punta Básica / Roma",
				"cost": 150,
				"dry_mass": 1500.0,
				"fuel_mass": 0.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.80,
				"desc": "Mucha resistencia del aire; frena el ascenso.",
				"icon": preload("res://scenes/nariz.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"nose_2": {
				"name": "Punta Cónica Estándar",
				"cost": 300,
				"dry_mass": 1200.0,
				"fuel_mass": 0.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.90,
				"desc": "Equilibrio entre peso y penetración atmosférica.",
				"icon": preload("res://scenes/nariz.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"nose_3": {
				"name": "Ojiva de Carbono",
				"cost": 550,
				"dry_mass": 900.0,
				"fuel_mass": 0.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.98,
				"desc": "Muy ligera y aerodinámica; minimiza pérdidas.",
				"icon": preload("res://scenes/nariz.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			}
		}
	},
	"cabin": {
		"category_title": "2. CABINA / CARGA (Estructura)",
		"options": {
			"cabin_1": {
				"name": "Cabina Acero Pesado",
				"cost": 200,
				"dry_mass": 4500.0,
				"fuel_mass": 0.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.0,
				"desc": "Barata y resistente, pero añade demasiada masa muerta.",
				"icon": preload("res://cuerpo.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"cabin_2": {
				"name": "Cabina Aluminio Aeroespacial",
				"cost": 400,
				"dry_mass": 3000.0,
				"fuel_mass": 0.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.0,
				"desc": "Peso estándar de misión orbital.",
				"icon": preload("res://cuerpo.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"cabin_3": {
				"name": "Cabina Compuesto Ultraligero",
				"cost": 700,
				"dry_mass": 1800.0,
				"fuel_mass": 0.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.0,
				"desc": "Maximiza la relación de masa (m_total / m_seca) de Tsiolkovski.",
				"icon": preload("res://cuerpo.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			}
		}
	},
	"tank": {
		"category_title": "3. TANQUES (Almacenamiento)",
		"options": {
			"tank_1": {
				"name": "Tanque Pequeño",
				"cost": 250,
				"dry_mass": 2000.0,
				"fuel_mass": 35000.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.0,
				"desc": "Poco combustible; solo sirve para vuelos suborbitales.",
				"icon": preload("res://scenes/tanque.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"tank_2": {
				"name": "Tanque Mediano",
				"cost": 500,
				"dry_mass": 3500.0,
				"fuel_mass": 75000.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.0,
				"desc": "Capacidad media; requiere buen motor para despegar.",
				"icon": preload("res://scenes/tanque.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"tank_3": {
				"name": "Tanque Criogénico XL",
				"cost": 850,
				"dry_mass": 4800.0,
				"fuel_mass": 125000.0,
				"thrust": 0.0,
				"isp": 0.0,
				"drag_factor": 0.0,
				"desc": "Enorme reserva de propelente; exige mucho empuje.",
				"icon": preload("res://scenes/tanque.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			}
		}
	},
	"engine": {
		"category_title": "4. PROPULSORES (Motores)",
		"options": {
			"engine_1": {
				"name": "Motor Químico Básico",
				"cost": 300,
				"dry_mass": 2500.0,
				"fuel_mass": 0.0,
				"thrust": 650000.0,
				"isp": 280.0,
				"drag_factor": 0.0,
				"desc": "Empuje y eficiencia bajos; solo levanta cohetes ligeros.",
				"icon": preload("res://scenes/thruster.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"engine_2": {
				"name": "Motor Ciclo Cerrado",
				"cost": 600,
				"dry_mass": 3500.0,
				"fuel_mass": 0.0,
				"thrust": 1400000.0,
				"isp": 330.0,
				"drag_factor": 0.0,
				"desc": "Buen empuje para levantar el tanque mediano.",
				"icon": preload("res://scenes/thruster.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			},
			"engine_3": {
				"name": "Motor de Alta Eficiencia",
				"cost": 950,
				"dry_mass": 4200.0,
				"fuel_mass": 0.0,
				"thrust": 1850000.0,
				"isp": 385.0,
				"drag_factor": 0.0,
				"desc": "Alto Isp y empuje brutal para cargar el tanque XL.",
				"icon": preload("res://scenes/thruster.png"),
				"frames": preload("res://rocket_builder/shuttle_base.tres")
			}
		}
	}
}

var selected_option_id: String = ""

func _ready() -> void:
	shuttle_anim.sprite_frames = RocketState.current_shuttle_frames
	if shuttle_anim.sprite_frames and shuttle_anim.sprite_frames.has_animation("idle"):
		shuttle_anim.play("idle")
		
	$MainLayout/UIPanel/TabStoreBtn.text = "TIENDA"
	$MainLayout/UIPanel/TabStatsBtn.text = "EQUIPO"
	$MainLayout/UIPanel/LaunchBtn.text = "LAUNCH"
	
	_update_money_ui()
	_populate_store()
	
	$MainLayout/UIPanel/TabStoreBtn.pressed.connect(_populate_store)
	$MainLayout/UIPanel/TabStatsBtn.pressed.connect(_show_equipped_summary)
	$MainLayout/UIPanel/LaunchBtn.pressed.connect(_on_launch_pressed)

func _populate_store() -> void:
	selected_option_id = ""
	for child in parts_list.get_children():
		child.queue_free()
		
	for slot_key in ["nose", "cabin", "tank", "engine"]:
		var category: Dictionary = PARTS_DATA[slot_key]
		
		# Encabezado de sección
		var header := Label.new()
		header.text = "\n" + category["category_title"]
		header.add_theme_color_override("font_color", Color(0.5, 1.0, 0.6))
		parts_list.add_child(header)
		
		# Opciones dentro de esta categoría
		for option_id in category["options"].keys():
			var data: Dictionary = category["options"][option_id]
			var is_equipped: bool = (RocketState.equipped_parts[slot_key].get("id", "") == option_id)
			
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(0, 72)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD
			btn.text = "  %s  |  $%d %s" % [
				data["name"],
				data["cost"],
				"  [EQUIPADO]" if is_equipped else ""
			]
			btn.pressed.connect(func(): _on_option_clicked(slot_key, option_id))
			parts_list.add_child(btn)

func _on_option_clicked(slot_key: String, option_id: String) -> void:
	var data: Dictionary = PARTS_DATA[slot_key]["options"][option_id]
	var is_equipped: bool = (RocketState.equipped_parts[slot_key].get("id", "") == option_id)
	
	item_preview.texture = data["icon"]
	
	# Armar texto de ficha técnica
	var specs := "Masa seca: %d kg" % int(data["dry_mass"])
	if data["fuel_mass"] > 0:
		specs += "\nCombustible: %d kg" % int(data["fuel_mass"])
	if data["thrust"] > 0:
		specs += "\nEmpuje: %d N" % int(data["thrust"])
	if data["isp"] > 0:
		specs += "\nIsp: %d s" % int(data["isp"])
	if data["drag_factor"] > 0:
		specs += "\nFactor arrastre: %.2f" % data["drag_factor"]
		
	if is_equipped:
		info_label.text = "%s [EQUIPADO]\n\n%s\n\n%s" % [data["name"], specs, data["desc"]]
		return
		
	if selected_option_id == option_id:
		if RocketState.money < data["cost"]:
			info_label.text = "Fondos insuficientes para %s ($%d)." % [data["name"], data["cost"]]
			return
		request_equip_part.rpc_id(1, slot_key, option_id)
	else:
		selected_option_id = option_id
		info_label.text = "%s — $%d\n%s\n\n%s\n\n[Clic de nuevo para comprar]" % [
			data["name"], data["cost"], specs, data["desc"]
		]

# --- COMPRA Y REEMPLAZO POR CATEGORÍA (HOST AUTORITATIVO) ---

@rpc("any_peer", "call_local", "reliable")
func request_equip_part(slot_key: String, option_id: String) -> void:
	if not multiplayer.is_server():
		return
	if not PARTS_DATA.has(slot_key) or not PARTS_DATA[slot_key]["options"].has(option_id):
		return
	if RocketState.equipped_parts[slot_key].get("id", "") == option_id:
		return
		
	var data: Dictionary = PARTS_DATA[slot_key]["options"][option_id]
	if RocketState.money < data["cost"]:
		return
		
	RocketState.money -= data["cost"]
	sync_part_equipped.rpc(slot_key, option_id, RocketState.money)

@rpc("authority", "call_local", "reliable")
func sync_part_equipped(slot_key: String, option_id: String, new_money: int) -> void:
	var data: Dictionary = PARTS_DATA[slot_key]["options"][option_id].duplicate()
	data["id"] = option_id
	
	RocketState.money = new_money
	RocketState.equipped_parts[slot_key] = data
	RocketState.recalculate_build_data()
	
	RocketState.current_shuttle_frames = data["frames"]
	shuttle_anim.sprite_frames = data["frames"]
	if shuttle_anim.sprite_frames and shuttle_anim.sprite_frames.has_animation("idle"):
		shuttle_anim.play("idle")
		
	_play_upgrade_fx()
	_update_money_ui()
	_populate_store()
	info_label.text = "¡%s equipado en %s!" % [data["name"], slot_key.to_upper()]

func _play_upgrade_fx() -> void:
	var base_scale := shuttle_anim.scale
	shuttle_anim.modulate = Color(1.7, 1.7, 1.7, 1.0)
	shuttle_anim.scale = base_scale * 1.1
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(shuttle_anim, "scale", base_scale, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(shuttle_anim, "modulate", Color.WHITE, 0.22)

# --- PESTAÑA DE PIEZAS EQUIPADAS ---

func _show_equipped_summary() -> void:
	for child in parts_list.get_children():
		child.queue_free()
		
	var lbl := Label.new()
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.custom_minimum_size = Vector2(10, 0)
	
	var text := "CONFIGURACIÓN ACTUAL DEL COHETE:\n\n"
	var labels_map := {
		"nose": "1. Punta / Nariz",
		"cabin": "2. Cabina / Carga",
		"tank": "3. Tanques",
		"engine": "4. Propulsores"
	}
	
	for slot_key in ["nose", "cabin", "tank", "engine"]:
		var part: Dictionary = RocketState.equipped_parts[slot_key]
		var part_name: String = part.get("name", "Sin equipar")
		text += "%s:\n  • %s\n\n" % [labels_map[slot_key], part_name]
		
	lbl.text = text
	parts_list.add_child(lbl)

func _update_money_ui() -> void:
	money_label.text = "$ " + str(RocketState.money)

var is_launching: bool = false

func _on_launch_pressed() -> void:
	if is_launching:
		return
		
	# 1. Validación mínima: el cohete necesita al menos tanque y motor para intentar despegar
	if RocketState.equipped_parts["tank"].is_empty() or RocketState.equipped_parts["engine"].is_empty():
		info_label.text = "Faltan componentes críticos: equipa al menos un Tanque y un Propulsor."
		return
		
	# 2. Pedir al servidor (Host) que valide, calcule y cambie de escena para todos
	request_launch.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func request_launch() -> void:
	if not multiplayer.is_server() or is_launching:
		return
		
	# Aseguramos que build_data esté al día con las 4 ranuras
	RocketState.recalculate_build_data()
	
	# =========================================================================
	# AQUÍ VAN TUS ECUACIONES REALES (consumiendo RocketState.build_data)
	# Variables disponibles:
	#   RocketState.build_data["dry_mass"]    (kg)
	#   RocketState.build_data["fuel_mass"]   (kg)
	#   RocketState.build_data["thrust"]      (N)
	#   RocketState.build_data["isp"]         (s)
	#   RocketState.build_data["drag_factor"] (0.80 - 0.98)
	# =========================================================================
	var success: bool = true
	var report: String = "Telemetría nominal. Órbita alcanzada."
	
	# Ejemplo temporal mientras metes tus fórmulas:
	if RocketState.build_data["thrust"] <= 0:
		success = false
		report = "Sin empuje."
	# =========================================================================
	
	go_to_launch_scene.rpc(success, report)

@rpc("authority", "call_local", "reliable")
func go_to_launch_scene(success: bool, report: String) -> void:
	is_launching = true
	RocketState.launch_success = success
	RocketState.launch_report = report
	
	# Cambia la ruta si guardaste tu escena de lanzamiento con otro nombre o carpeta
	get_tree().change_scene_to_file("res://scenes/launch_scene.tscn")
