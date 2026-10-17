class_name CharaCard
extends Control

# 出战（前台）角色用金色边框，后台角色用黑色边框
const BORDER_ACTIVE := preload("res://Assets/images/Character_Border_Front.png")
const BORDER_INACTIVE := preload("res://Assets/images/Character_Border_Back.png")

var is_active: bool = true

@onready var _border: TextureRect = get_node_or_null("border") as TextureRect


func _ready() -> void:
	set_process(false)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	var mouse := get_local_mouse_position()
	var x := (mouse.x / size.x - 0.5) * 2
	var y := (mouse.y / size.y - 0.5) * 2


func set_active_card(active: bool) -> void:
	is_active = active
	if _border == null:
		return
	_border.texture = BORDER_ACTIVE if active else BORDER_INACTIVE


func _on_mouse_entered() -> void:
	set_process(true)


func _on_mouse_exited() -> void:
	set_process(false)


func _on_clicked() -> void:
	var player := _get_player()
	if player == null:
		return
	player._on_character_clicked(self)


func _get_player() -> Node:
	var node := get_parent()
	while node:
		if node is Player:
			return node
		node = node.get_parent()
	return null
