# DeckPile.gd
class_name DeckPile
extends Control

signal deck_clicked

@onready var count_label : Label = $CountLabel

var _cards : Array[CardData] = []


func setup(cards: Array[CardData]) -> void:
	_cards = cards
	_update_label()


func get_cards() -> Array[CardData]:
	return _cards


func _update_label() -> void:
	count_label.text = str(_cards.size())


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		deck_clicked.emit()
