extends Control

func _ready() -> void:
	var centre_square = $centre_square
	var left_panel := $left_panel
	var right_panel := $right_panel
	var right_curve1 := $Control/Polygon2D
	
	
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(centre_square, "scale", Vector2(5, 5), 2)
	
	tween.tween_property(left_panel, "size", Vector2(1920/2, left_panel.size.y), 2)
	tween.set_parallel().tween_property(right_panel, "size", Vector2(1920/2, right_panel.size.y), 2)
	
	tween.set_parallel().tween_property(right_curve1, "scale", Vector2(1, 1), 0.5).set_delay(2)
	
