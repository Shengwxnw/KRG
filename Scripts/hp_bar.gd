class_name HPBar
extends Control

signal hp_changed(new_hp: int, max_hp: int)
signal died

@export var max_hp: int = 10
@export var player_id: int = 1

var current_hp: int:
	get: return _current_hp

var _current_hp: int = 10
var _displayed_hp: float = 10.0
var _shield: int = 0

@onready var hp_fill: Panel = $hp
@onready var hurt_fill: Panel = $hurt
@onready var hp_label: Label = $hp_label
@onready var shield_label: Label = $shield_label
@onready var damage_container: Node2D = $damage_container

var _hurt_width: float = 1.0
var _tween_hurt: Tween
var _tween_hp: Tween


func _ready() -> void:
	if hp_label:
		hp_label.text = "%d/%d" % [_current_hp, max_hp]
	_displayed_hp = _current_hp
	_update_hp_bar()


func take_damage(amount: int, from_card: CardData = null) -> void:
	if amount <= 0:
		return
	
	var actual_damage := mini(amount, _current_hp)
	_current_hp -= actual_damage
	
	_show_damage_number(actual_damage)
	_hp_changed()
	
	if _current_hp <= 0:
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0:
		return
	
	_current_hp = mini(_current_hp + amount, max_hp)
	_show_heal_number(amount)
	_hp_changed()


func _hp_changed() -> void:
	hp_changed.emit(_current_hp, max_hp)
	
	if hp_label:
		hp_label.text = "%d/%d" % [_current_hp, max_hp]
	if shield_label:
		shield_label.text = "🛡%d" % _shield if _shield > 0 else ""
	
	_hurt_width = _displayed_hp / max_hp
	_update_hurt_bar()
	_animate_hp_change()


func set_shield(amount: int) -> void:
	_shield = amount
	if shield_label:
		shield_label.text = "🛡%d" % _shield if _shield > 0 else ""


func _animate_hp_change() -> void:
	if _tween_hp:
		_tween_hp.kill()
	
	_tween_hp = create_tween()
	_tween_hp.tween_property(self, "_displayed_hp", _current_hp, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_hp.tween_callback(_update_hp_bar)


func _update_hp_bar() -> void:
	var ratio := _displayed_hp / max_hp
	hp_fill.scale.x = ratio


func _update_hurt_bar() -> void:
	if _tween_hurt:
		_tween_hurt.kill()
	
	_tween_hurt = create_tween()
	_tween_hurt.tween_property(hurt_fill, "scale:x", _hurt_width, 0.8)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _show_damage_number(amount: int) -> void:
	var label := Label.new()
	label.text = "-%d" % amount
	label.add_theme_font_size_override("font_size", 32)
	label.modulate = Color(1, 0.3, 0.3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var container_rect := damage_container.get_global_transform_with_canvas()
	label.position = Vector2(randf_range(-30, 30), 0)
	damage_container.add_child(label)
	
	var tween := create_tween()
	tween.tween_property(label, "position:y", -80, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(label.queue_free)


func _show_heal_number(amount: int) -> void:
	var label := Label.new()
	label.text = "+%d" % amount
	label.add_theme_font_size_override("font_size", 28)
	label.modulate = Color(0.3, 1, 0.5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	label.position = Vector2(randf_range(-30, 30), 0)
	damage_container.add_child(label)
	
	var tween := create_tween()
	tween.tween_property(label, "position:y", -60, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(label.queue_free)
