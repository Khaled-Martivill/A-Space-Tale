extends Node2D

const G0: float = 9.81
const TARGET_MARS_DV: float = 8500.0

@onready var cohete_despegue: AnimatedSprite2D = $CoheteDespegue
@onready var cohete_cayendo: Sprite2D = $CoheteCayendo

var resultado_vuelo: String = ""

func _ready() -> void:
	cohete_cayendo.visible = false
	cohete_despegue.visible = true
	
	# 1. Calcular el resultado con los datos de RocketState
	resultado_vuelo = evaluate_flight()
	print("Resultado de simulación: ", resultado_vuelo)
	
	# 2. Ejecutar la animación según el cálculo
	if resultado_vuelo == "CRASH_ON_PAD":
		# No tiene fuerza para despegar: vibra un poco y falla en plataforma
		animar_fallo_plataforma()
	else:
		# Tiene TWR > 1: reproduce la animación de despegue hacia arriba
		cohete_despegue.play("default")
		await cohete_despegue.animation_finished
		
		if resultado_vuelo == "SUCCESS":
			print("¡Despegue exitoso!")
			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
		else:
			# Se quedó corto de Delta-V -> Cae de regreso
			animar_caida()

func evaluate_flight() -> String:
	var data = RocketState.build_data
	var m_dry: float = data["dry_mass"]
	var m_fuel: float = data["fuel_mass"]
	var m_total: float = m_dry + m_fuel
	var thrust: float = data["thrust"]
	var isp: float = data["isp"]
	var drag: float = data["drag_factor"]
	
	var twr: float = thrust / (m_total * G0)
	if twr <= 1.0:
		return "CRASH_ON_PAD"
	
	var delta_v: float = isp * G0 * log(m_total / m_dry) * drag
	
	if delta_v < TARGET_MARS_DV:
		return "LOST_IN_ORBIT"
	else:
		return "SUCCESS_MARS"

func animar_fallo_plataforma() -> void:
	# Muestra solo los primeros frames de encendido y sacude el cohete
	var pos_original = cohete_despegue.position
	var tween = create_tween()
	for i in range(10):
		tween.tween_property(cohete_despegue, "position:x", pos_original.x + 6, 0.05)
		tween.tween_property(cohete_despegue, "position:x", pos_original.x - 6, 0.05)
	tween.tween_property(cohete_despegue, "position", pos_original, 0.05)
	await tween.finished
	# Aquí puedes mandar a pantalla de Game Over o regresar al taller
	get_tree().change_scene_to_file("res://rocket_builder/rocket_builder.tscn")

func animar_caida() -> void:
	cohete_despegue.visible = false
	cohete_cayendo.visible = true
	
	# Posiciona el sprite en picada arriba del centro y lo hace caer hasta el suelo
	var centro_x = get_viewport_rect().size.x / 2.0
	var suelo_y = get_viewport_rect().size.y * 0.88
	
	cohete_cayendo.position = Vector2(centro_x, -80)
	cohete_cayendo.rotation = deg_to_rad(135) # Lo inclina apuntando hacia abajo-izquierda
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN) # Acelera por gravedad
	tween.tween_property(cohete_cayendo, "position:y", suelo_y, 1.8)
	await tween.finished
	
	# Al tocar el suelo, regresa al constructor (o cambia a escena de explosión)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://rocket_builder/rocket_builder.tscn")
