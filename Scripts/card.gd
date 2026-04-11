# Card.gd
class_name Card
extends Control

signal card_played(card: Card)

@onready var cost_label : Label       = $cost_label
@onready var type_icon  : TextureRect = $type_icon

# 没有美术资源前用颜色代替类型图标
const TYPE_COLORS := {
	CardData.CardType.ATTACK  : Color(0.85, 0.3,  0.3 ),
	CardData.CardType.DEFENSE : Color(0.3,  0.55, 0.85),
	CardData.CardType.BUFF    : Color(0.4,  0.75, 0.45),
	CardData.CardType.SUMMON  : Color(0.7,  0.5,  0.85),
}

var data     : CardData
var playable : bool = true

const HOVER_LIFT     := -24.0
const HOVER_DURATION := 0.12
const DRAG_THRESHOLD := 10.0

var _dragging       : bool    = false
var _drag_start_pos : Vector2 = Vector2.ZERO
var _origin_pos     : Vector2 = Vector2.ZERO
var _press_pos      : Vector2 = Vector2.ZERO


func setup(card_data: CardData) -> void:
	data = card_data
	cost_label.text = str(data.cost)
	# 用颜色区分类型，有图标资源后替换
	var panel := $bg as Panel
	var style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color = TYPE_COLORS.get(data.type, Color.WHITE)
	panel.add_theme_stylebox_override("panel", style)


func set_playable(can_play: bool) -> void:
	playable = can_play
	modulate = Color.WHITE if can_play else Color(0.5, 0.5, 0.5, 0.9)


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func _on_mouse_entered() -> void:
	if _dragging or not playable:
		return
	_tween_y(HOVER_LIFT)


func _on_mouse_exited() -> void:
	if _dragging:
		return
	_tween_y(0.0)


func _on_gui_input(event: InputEvent) -> void:
	if not playable:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_pos      = event.global_position
			_drag_start_pos = event.global_position
			_origin_pos     = global_position
		else:
			if _dragging:
				_on_drag_released()
			else:
				card_played.emit(self)

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _dragging and event.global_position.distance_to(_press_pos) > DRAG_THRESHOLD:
			_dragging = true
			z_index   = 10
		if _dragging:
			global_position = _origin_pos + (event.global_position - _drag_start_pos)


func _on_drag_released() -> void:
	_dragging = false
	z_index   = 0
	var play_zone_y := get_viewport().get_visible_rect().size.y * 0.6
	if global_position.y < play_zone_y:
		card_played.emit(self)
	else:
		var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", _origin_pos, 0.25)


func _tween_y(target_y: float) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", target_y, HOVER_DURATION)
