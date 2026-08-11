extends Control

@onready var bg          := $BG
@onready var card_name   := $Name/RichTextLabel
@onready var jacket      := $Jacket
@onready var description := $Description/RichTextLabel
@onready var play_button := $Play
@onready var sell_button := $Sell

var _current_card: Card = null


func _ready() -> void:
	position.x = get_viewport_rect().size.x
	SignalBus.card_clicked.connect(_open)
	SignalBus.close_side_bar.connect(_close)


func _open(card: Card) -> void:
	_current_card = card
	SignalBus.is_side_bar_open = true

	var data := card.card_data
	if data:
		card_name.text = "[center][font_size=40]%s[/font_size][/center]" % data.card_name
		var type_label := ""
		match data.type:
			CardData.CardType.NOTE:   type_label = "伤害: %d" % data.damage_value
			CardData.CardType.HEAL:   type_label = "回复: %d" % data.damage_value
			CardData.CardType.MISS:   type_label = "闪避"
			_:                        type_label = _type_name(data.type)
		description.text = "[center][font_size=24]费用: %d | %s\n%s[/font_size][/center]" % [data.cost, type_label, data.description]
		play_button.disabled = false
		sell_button.disabled = false
	else:
		play_button.disabled = true
		sell_button.disabled = true

	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:x", get_viewport_rect().size.x - size.x, 0.4)


func _close() -> void:
	_current_card = null
	SignalBus.is_side_bar_open = false
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:x", get_viewport_rect().size.x, 0.4)


func _on_play_pressed() -> void:
	if _current_card == null:
		return
	SignalBus.card_play_requested.emit(_current_card)
	_close()


func _on_sell_pressed() -> void:
	if _current_card == null:
		return
	SignalBus.card_sell_requested.emit(_current_card)
	_close()


func _type_name(ctype: int) -> String:
	match ctype:
		CardData.CardType.EQUIPMENT: return "装备"
		CardData.CardType.FIELD:     return "场地"
		CardData.CardType.EVENT:     return "事件"
		_:                           return ""
