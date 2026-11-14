extends Control

@onready var ip_input: LineEdit = $VBoxContainer/IPInput
@onready var connect_btn: Button = $VBoxContainer/ConnectButton
@onready var status_label: Label = $VBoxContainer/StatusLabel

func _ready() -> void:
	connect_btn.pressed.connect(_on_connect_pressed)
	Network.connection_failed_msg.connect(func(msg: String):
		status_label.text = msg
		connect_btn.disabled = false
	)

func _on_connect_pressed() -> void:
	connect_btn.disabled = true
	status_label.text = "Conectando a %s..." % ip_input.text
	Network.join_server(ip_input.text)
