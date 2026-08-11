extends Control
class_name Card

var card_data: CardData
var show_cards : bool = false:
	set(v):
		show_cards = v
		_update_texture()

var type_rect: TextureRect
var cost_rect: TextureRect
var name_label: Label

const EMPTY_TEXTURE := "res://Assets/images/empty.png"
const BACK_TEXTURE  := "res://Assets/images/others/Card_back.png"


func _ready() -> void:
	type_rect = $Type as TextureRect
	cost_rect = $Cost as TextureRect
	name_label = $Name as Label
	_update_texture()


func _update_texture() -> void:
	if type_rect == null:
		return
	if show_cards:
		if card_data and _is_basic(card_data.type):
			name_label.visible = false
		else:
			name_label.visible = show_cards
		cost_rect.visible = true
	else:
		type_rect.texture = load(BACK_TEXTURE)
		name_label.visible = false
		cost_rect.visible = false


func setup(data: CardData) -> void:
	card_data = data
	if name_label:
		name_label.text = data.card_name

	var is_basic := _is_basic(data.type)
	if is_basic:
		var filename := data.card_name.to_lower().replace(" ", "_") + ".png"
		type_rect.texture = load("res://Assets/images/cards/basic/" + filename)
		name_label.visible = false
	else:
		type_rect.texture = load(EMPTY_TEXTURE)
		name_label.visible = show_cards

	cost_rect.texture = load("res://Assets/images/costs/%d-1.png" % data.cost)
	_update_texture()


func _is_basic(ctype: int) -> bool:
	return ctype in [CardData.CardType.NOTE, CardData.CardType.MISS, CardData.CardType.HEAL]


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if !SignalBus.is_side_bar_open:
			SignalBus.card_clicked.emit(self)
			accept_event()
