# HandArea.gd
class_name HandArea
extends Control

signal closed
signal card_played(card: Card)

@export var card_scene : PackedScene

const CARD_WIDTH     := 120.0
const CARD_SPACING   := 20.0
const SLIDE_DURATION := 0.35

var _cards : Array[Card] = []
var _is_open : bool = false


func open(card_data_list: Array[CardData]) -> void:
	if _is_open:
		return
	_is_open = true
	show()

	# 先把整个手牌区从屏幕下方滑入
	var viewport_h := get_viewport().get_visible_rect().size.y
	position.y = viewport_h
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", viewport_h * 0.5, SLIDE_DURATION)
	await tween.finished

	# 生成手牌并水平排列
	_spawn_cards(card_data_list)


func close() -> void:
	if not _is_open:
		return
	_is_open = false

	var viewport_h := get_viewport().get_visible_rect().size.y
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", viewport_h, SLIDE_DURATION)
	await tween.finished

	_clear_cards()
	hide()
	closed.emit()


func _spawn_cards(card_data_list: Array[CardData]) -> void:
	var total_w := card_data_list.size() * CARD_WIDTH \
				 + (card_data_list.size() - 1) * CARD_SPACING
	var start_x := (size.x - total_w) / 2.0

	for i in card_data_list.size():
		var card := card_scene.instantiate() as Card
		add_child(card)
		card.setup(card_data_list[i])
		card.position = Vector2(start_x + i * (CARD_WIDTH + CARD_SPACING), 40.0)
		card.card_played.connect(_on_card_played)
		_cards.append(card)


func _on_card_played(card: Card) -> void:
	card_played.emit(card)
	_cards.erase(card)
	card.queue_free()
	_rearrange()


func _rearrange() -> void:
	var total_w := _cards.size() * CARD_WIDTH \
				 + (_cards.size() - 1) * CARD_SPACING
	var start_x := (size.x - total_w) / 2.0

	for i in _cards.size():
		var tween := _cards[i].create_tween() \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(
			_cards[i], "position:x",
			start_x + i * (CARD_WIDTH + CARD_SPACING),
			0.2
		)


func _clear_cards() -> void:
	for card in _cards:
		card.queue_free()
	_cards.clear()
