# PhaseBanner.gd
extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label
@onready var overlay: Panel = $Overlay

const BANNER_HEIGHT := 100
const SLIDE_DURATION := 0.4
const HOLD_DURATION := 2.0

func _ready() -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate.a = 0

func show_phase(text: String) -> void:
	visible = true
	label.text = text

	var viewport_h := get_viewport().get_visible_rect().size.y
	var viewport_w := get_viewport().get_visible_rect().size.x
	var center_y := (viewport_h - BANNER_HEIGHT) / 2.0

	panel.size = Vector2(viewport_w, BANNER_HEIGHT)
	panel.position = Vector2(0, -BANNER_HEIGHT) # 从屏幕上方开始
	overlay.modulate.a = 0.0

	var tween := create_tween().set_parallel(false)

	# 滑入 + 阴影同时出现
	tween.set_parallel(true)
	tween.tween_property(panel, "position:y", center_y, SLIDE_DURATION) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(overlay, "modulate:a", 0.4, SLIDE_DURATION) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 停留
	tween.set_parallel(false)
	tween.tween_interval(HOLD_DURATION)

	# 滑出 + 阴影同时消失
	tween.set_parallel(true)
	tween.tween_property(panel, "position:y", viewport_h, SLIDE_DURATION) \
		 .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(overlay, "modulate:a", 0.0, SLIDE_DURATION) \
		 .set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	await tween.finished
	visible = false
