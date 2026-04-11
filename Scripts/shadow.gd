extends Control


@export var panel: Panel
func _ready() -> void:
	size = get_viewport_rect().size
	panel.modulate.a = 0

func _cover_shadow():
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.9, 1)
	tween.tween_callback(panel.queue_free)
