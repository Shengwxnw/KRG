extends Control

func _ready() -> void:
	set_process(false)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	var mouse := get_local_mouse_position()
	var x := (mouse.x / size.x - 0.5) * 2
	var y := (mouse.y / size.y - 0.5) * 2
	$BG.material.set("shader_parameter/tilt_x", x * 0.002)
	$BG.material.set("shader_parameter/tilt_y", -y * 0.002)
	$character.material.set("shader_parameter/tilt_x", x * 0.002)
	$character.material.set("shader_parameter/tilt_y", -y * 0.002)

func _on_mouse_entered() -> void:
	set_process(true)

func _on_mouse_exited() -> void:
	set_process(false)
	$BG.material.set("shader_parameter/tilt_x", 0.0)
	$BG.material.set("shader_parameter/tilt_y", 0.0)
	$character.material.set("shader_parameter/tilt_x", 0.0)
	$character.material.set("shader_parameter/tilt_y", 0.0)

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
