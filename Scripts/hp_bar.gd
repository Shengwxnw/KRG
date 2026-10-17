# HPBar.gd
class_name HPBar
extends Control

const FILL_COLOR := Color(0.0, 0.6745, 0.2028, 1.0)  # 绿色血量填充
const HURT_COLOR := Color(0.7838, 0.2048, 0.0, 1.0)  # 红色掉血残影
const TRACK_NODES := ["hp", "hurt", "bg"]  # 场景里画好的血条轨道

var max_hp: int = 100
var current_hp: int = 0

var _hp_panel: Control
var _hurt_panel: Control
var _label: Label

var _bar_rect: Rect2 = Rect2()
var _bar_width: float = 0.0
var _hurt_tween: Tween
var _initialized: bool = false


func init() -> void:
	_label = get_node_or_null("hp_label") as Label
	_bar_rect = _resolve_bar_rect()
	_bar_width = _bar_rect.size.x

	# 场景可以自带 hurt/hp 轨道；缺少时按背景美术自动补出来，
	# 这样替换血条贴图不需要同步改脚本。
	_hurt_panel = _resolve_panel("hurt", HURT_COLOR)
	_hp_panel = _resolve_panel("hp", FILL_COLOR)
	for panel in [_hurt_panel, _hp_panel]:
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	max_hp = GameManager.MAX_HP
	current_hp = max_hp
	if _label:
		_label.text = _format_hp()
	_set_bar_fill(1.0)


func set_hp(hp_val: int) -> void:
	var prev_hp := current_hp
	current_hp = clampi(hp_val, 0, max_hp)
	if _label:
		_label.text = _format_hp()

	var fill := float(current_hp) / float(max_hp)
	_set_bar_fill(fill)

	if _hurt_panel and _initialized and prev_hp > current_hp:
		_animate_hurt(prev_hp, current_hp)
	elif _hurt_panel:
		_hurt_panel.visible = false
	_initialized = true


func _set_bar_fill(fill: float) -> void:
	if _hp_panel == null:
		return
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
	if _label == null:
		return
	# Label 不支持 BBCode，护盾直接用纯文本追加
	if amount > 0:
		_label.text = "%s  🛡%d" % [_format_hp(), amount]
	else:
		_label.text = _format_hp()


# 血量显示为百分比（例：36%）
func _format_hp() -> String:
	if max_hp <= 0:
		return "0%"
	return "%d%%" % roundi(float(current_hp) / float(max_hp) * 100.0)


# ── 内部：解析血条几何与填充层 ──────────────────

func _resolve_panel(node_name: String, color: Color) -> Control:
	var existing := get_node_or_null(node_name) as Control
	if existing:
		return existing  # 几何交给场景，脚本只驱动宽度

	var panel := Panel.new()
	panel.name = node_name
	var style := StyleBoxFlat.new()
	style.bg_color = color
	panel.add_theme_stylebox_override("panel", style)
	panel.layout_mode = 0  # 绝对坐标：与 _bar_rect 同一坐标系
	panel.position = _bar_rect.position
	panel.size = _bar_rect.size
	add_child(panel)
	if _label and _label.get_parent() == self:
		move_child(panel, _label.get_index())
	return panel


func _resolve_bar_rect() -> Rect2:
	# 场景里画好的轨道面板就是血条的可用矩形
	for node_name in TRACK_NODES:
		var track := get_node_or_null(node_name) as Control
		if track and track.size.x > 0.0:
			return Rect2(track.position, track.size)

	# 只有背景美术时，退回到美术自身的矩形
	var sprite := _find_background_sprite()
	if sprite and sprite.texture:
		var tex_size := Vector2(sprite.texture.get_size()) * sprite.scale
		var origin := sprite.position + sprite.offset
		if sprite.centered:
			origin -= tex_size * 0.5
		return Rect2(origin, tex_size)

	return Rect2(Vector2.ZERO, size)


func _find_background_sprite() -> Sprite2D:
	for child in get_children():
		if child is Sprite2D:
			return child
	return null
