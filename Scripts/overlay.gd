# Overlay.gd
extends Panel

func _ready() -> void:
	modulate.a = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_in(duration: float = 0.3) -> void:
	visible = true
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.8, duration)
	await tween.finished
	visible = false


func fade_out(duration: float = 0.3) -> void:
	visible = true
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	await tween.finished
	visible = false
