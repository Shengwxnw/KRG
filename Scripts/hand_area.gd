# HandArea.gd
class_name HandArea
extends Node

signal closed
signal card_played(card: Card)

@onready var card_scene : PackedScene = preload("res://Scenes/card.tscn")
@onready var hand_area  : Panel      = $HandArea
@onready var overlay    : Panel      = $overlay

const CARD_SCALE   := 0.72
const CARD_WIDTH   := 300.0
const CARD_HEIGHT  := 420.0
const CARD_STEP    := 208.0

var _cards   : Array[Card]   = []
var _is_open : bool          = false


func _ready() -> void:
	hand_area.position.y = get_viewport().size.y


func open(card_data_list: Array[CardData]) -> void:
	InputManager.register_open_hand(self)
	var card_w := CARD_WIDTH * CARD_SCALE
	var card_h := CARD_HEIGHT * CARD_SCALE
	var total_w := card_w + (card_data_list.size() - 1) * CARD_STEP
	var start_x := (hand_area.size.x - total_w) / 2.0
	var start_y := (hand_area.size.y - card_h) / 2.0 + 20

	for i in card_data_list.size():
		var c := card_scene.instantiate() as Card
		c.scale = Vector2(CARD_SCALE, CARD_SCALE)
		c.position = Vector2(start_x + i * CARD_STEP, start_y)
		c.z_index = i
		hand_area.add_child(c)
		c.show_cards = true
		c.setup(card_data_list[i])
		_cards.append(c)

	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(hand_area, "position:y", get_viewport().size.y / 2, 0.3)
	tween.tween_callback(func(): _is_open = true)


func close() -> void:
	InputManager.unregister_open_hand(self)
	_is_open = false
	overlay.fade_out(0.3)
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(hand_area, "position:y", get_viewport().size.y, 0.3)
	for c in _cards:
		c.queue_free()
	_cards.clear()
	closed.emit()


func remove_card(card: Card) -> void:
	_cards.erase(card)
	card.queue_free()
