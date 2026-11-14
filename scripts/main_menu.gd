extends Control

@onready var start_btn: Button = $VBoxContainer/StartButton
@onready var ip_input: LineEdit = $VBoxContainer/IPInput
@onready var connect_btn: Button = $VBoxContainer/ConnectButton
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var exit_btn: Button = $VBoxContainer/ExitButton

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	connect_btn.pressed.connect(_on_connect_pressed)
	exit_btn.pressed.connect(get_tree().quit)
	Network.connection_failed_msg.connect(_on_connection_failed)

func _on_start_pressed() -> void:
	start_btn.disabled = true
	Network.start_local()

func _on_connect_pressed() -> void:
	connect_btn.disabled = true
	status_label.text = "Conectando a %s..." % ip_input.text
	Network.join_server(ip_input.text)

func _on_connection_failed(msg: String) -> void:
	status_label.text = msg
	connect_btn.disabled = false
