extends Control

@onready var mode_box: VBoxContainer = $CenterBox/ModeSelectBox
@onready var online_box: VBoxContainer = $CenterBox/OnlineBox
@onready var local_btn: Button = $CenterBox/ModeSelectBox/LocalButton
@onready var online_menu_btn: Button = $CenterBox/ModeSelectBox/OnlineMenuButton
@onready var ip_input: LineEdit = $CenterBox/OnlineBox/IPInput
@onready var connect_btn: Button = $CenterBox/OnlineBox/ConnectButton
@onready var back_btn: Button = $CenterBox/OnlineBox/BackButton
@onready var status_label: Label = $CenterBox/OnlineBox/StatusLabel

func _ready() -> void:
    local_btn.pressed.connect(_on_local_pressed)
    online_menu_btn.pressed.connect(_on_online_menu_pressed)
    back_btn.pressed.connect(_on_back_pressed)
    connect_btn.pressed.connect(_on_connect_pressed)
    Network.connection_failed_msg.connect(_on_connection_failed)

func _on_local_pressed() -> void:
    local_btn.disabled = true
    online_menu_btn.disabled = true
    Network.start_local()

func _on_online_menu_pressed() -> void:
    mode_box.visible = false
    online_box.visible = true
    status_label.text = ""
    connect_btn.disabled = false

func _on_back_pressed() -> void:
    online_box.visible = false
    mode_box.visible = true
    status_label.text = ""

func _on_connect_pressed() -> void:
    connect_btn.disabled = true
    back_btn.disabled = true
    status_label.text = "Conectando a %s..." % ip_input.text
    Network.join_server(ip_input.text)

func _on_connection_failed(msg: String) -> void:
    status_label.text = msg
    connect_btn.disabled = false
    back_btn.disabled = false
