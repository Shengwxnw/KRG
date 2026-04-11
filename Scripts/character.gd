extends Control

func _process(delta):
	var mouse = get_local_mouse_position()
	
	var x = (mouse.x / size.x - 0.5) * 2
	var y = (mouse.y / size.y - 0.5) * 2

	$BG.material.set("shader_parameter/tilt_x", x * 0.002)
	$BG.material.set("shader_parameter/tilt_y", -y * 0.002)
	$character.material.set("shader_parameter/tilt_x", x * 0.002)
	$character.material.set("shader_parameter/tilt_y", -y * 0.002)


func _on_clicked() -> void:
	pass
