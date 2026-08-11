# HPBar.gd
class_name HPBar
extends Control

var max_hp: int = 100
var current_hp: int = 0

var _hp_panel: Panel
var _hurt_panel: Panel
var _label: Label

var _bar_width: float = 0.0
var _hurt_tween: Tween
var _initialized: bool = false


func init() -> void:
	_hp_panel = get_node("hp") as Panel
	_hurt_panel = get_node("hurt") as Panel
	_label = get_node("hp_label") as Label
	var bg_panel := get_node("bg") as Panel
	_bar_width = bg_panel.size.x
	_hp_panel.layout_mode = 0
	_hurt_panel.layout_mode = 0
	_hp_panel.size.y = bg_panel.size.y
	_hurt_panel.size.y = bg_panel.size.y
	max_hp = GameManager.MAX_HP
	current_hp = max_hp
	_label.text = "%d/%d" % [current_hp, max_hp]
	_set_bar_fill(1.0)


func set_hp(hp_val: int) -> void:
	var prev_hp := current_hp
	current_hp = clampi(hp_val, 0, max_hp)
	_label.text = "%d/%d" % [current_hp, max_hp]

	var fill := float(current_hp) / float(max_hp)
	_set_bar_fill(fill)

	if _initialized and prev_hp > current_hp:
		_animate_hurt(prev_hp, current_hp)
	else:
		_hurt_panel.visible = false
	_initialized = true


func _set_bar_fill(fill: float) -> void:
	_hp_panel.visible = fill > 0
	_hp_panel.size.x = _bar_width * fill


func _animate_hurt(prev_hp: int, new_hp: int) -> void:
	var prev_fill := float(prev_hp) / float(max_hp)
	var new_fill := float(new_hp) / float(max_hp)

	_hurt_panel.visible = true
	_hurt_panel.size.x = _bar_width * prev_fill

	if _hurt_tween:
		_hurt_tween.kill()

	_hurt_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_hurt_tween.tween_interval(0.5)
	_hurt_tween.tween_property(_hurt_panel, "size:x", _bar_width * new_fill, 0.35)
	_hurt_tween.tween_callback(func(): _hurt_panel.visible = false)


func set_shield(amount: int) -> void:
	if amount > 0:
		_label.text = "%d/%d [i]🛡%d[/i]" % [current_hp, max_hp, amount]
	else:
		_label.text = "%d/%d" % [current_hp, max_hp]
