extends Node
class_name Player

var side: int
var opponent : Player
var state

var hand_manager: HandManager
var active_char: int = 1

var equip_slots: Array[Dictionary] = [{}, {}]
var field_slots: Array[Dictionary] = [{}, {}]

@onready var equip_nodes: Array[Control] = [$Equipment/square, $Equipment/square2]
@onready var field_nodes: Array[Control] = [$Field/square, $Field/square3]

const DECK_START_X  := 1320
const DECK_SPACING  := 40
const DECK_P1_Y     := 886.975
const DECK_P2_Y     := 200.975

@onready var character1 : Control = $Chara1
@onready var character2 : Control = $Chara2
@onready var equipment: Node = $Equipment
@onready var hand: Node = $Hand
@onready var field: Node = $Field
@onready var deck: Node = $Deck
@onready var deck_button: Button = $Button
@onready var game: Node
@onready var card_scene: PackedScene = preload("res://Scenes/card.tscn")

var _chara1_original: Vector2
var _chara2_original: Vector2
var _chara1_active: Vector2
var _chara2_active: Vector2


func _ready() -> void:
	add_to_group("player")
	hand.closed.connect(_hand_closed)
	_attach_hand_manager()
	_hide_all_slots()

	if side == 1 and opponent.deck_button != null:
		opponent.deck_button.queue_free()
	
	setup_layout()
	setup_cards()
	_store_positions()
	_apply_active_position()
	GameManager.active_character_changed.connect(_on_active_character_changed)


func _attach_hand_manager() -> void:
	var hm_node := $HandManager
	hm_node.set_script(preload("res://Scripts/hand_manager.gd"))
	hand_manager = hm_node
	hand_manager.deck = CardData.make_full_deck()
	hand_manager.deck.shuffle()
	hand_manager.cards = []
	for _i in 5:
		hand_manager.draw_from_deck(1)

func setup_layout() -> void:
	if side == 2:
		for child in get_children():
			if child is Control:
				child.position.y = 1200 - child.position.y - child.size.y
			else:
				for nieto in child.get_children():
					if nieto is Control:
						nieto.position.y = 1200 - nieto.position.y - nieto.size.y * nieto.scale.x


func _store_positions() -> void:
	_chara1_original = character1.position
	_chara2_original = character2.position
	var forward_dir := -1 if side == 1 else 1
	_chara1_active = _chara1_original + Vector2(0, forward_dir * 100)
	_chara2_active = _chara2_original + Vector2(0, forward_dir * 100)


func _apply_active_position() -> void:
	if active_char == 1:
		character1.position = _chara1_active
		character2.position = _chara2_original
	else:
		character1.position = _chara1_original
		character2.position = _chara2_active


func switch_character() -> void:
	GameManager.switch_active_character(side)


func _on_character_clicked(char_node: Control) -> void:
	var tm := get_tree().get_first_node_in_group("turn_manager")
	if tm == null or not tm.is_in_action_phase() or tm.current_acting_player != side:
		return

	var char_id := _get_char_id(char_node)
	if char_id == 0 or char_id == active_char:
		return

	if not GameManager.spend_coins(side, 1):
		print("硬币不足，无法切换角色")
		return

	CoinFlyManager.remove_coins_from_bar(1)
	switch_character()
	tm.notify_action_done(side)


func _get_char_id(char_node: Control) -> int:
	if char_node == character1:
		return 1
	if char_node == character2:
		return 2
	return 0


func _on_active_character_changed(player_id: int, new_char: int) -> void:
	if player_id != side:
		return
	var prev := active_char
	active_char = new_char
	_animate_char_switch(prev, new_char)


func _animate_char_switch(prev: int, new_char: int) -> void:
	var prev_node := character1 if prev == 1 else character2
	var new_node := character1 if new_char == 1 else character2
	var prev_target := _chara1_original if prev == 1 else _chara2_original
	var new_target := _chara1_active if new_char == 1 else _chara2_active

	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(prev_node, "position", prev_target, 0.35)
	tween.parallel().tween_property(new_node, "position", new_target, 0.35)


func _on_deck_pressed() -> void:
	var tm := get_tree().get_first_node_in_group("turn_manager")
	if tm == null or not tm.is_in_action_phase() or tm.current_acting_player != side:
		return
	deck_button.visible = false
	for card in deck.get_children():
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		tween.tween_property(card, "position:y", card.position.y + 500, 0.2)
	hand.overlay.fade_in(0.5)
	hand.open(hand_manager.cards)
	
func setup_cards():
	for i in range(len(hand_manager.cards)):
		var c = card_scene.instantiate()
		c.position = _get_deck_card_pos(i)
		deck.add_child(c)
		if side == 1:
			c.show_cards = true
		c.setup(hand_manager.cards[i])
		
func _hand_closed() -> void:
	for card in deck.get_children():
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		tween.tween_property(card, "position:y", card.position.y - 500, 0.2)
	deck_button.visible = true


func animate_draw(cards_data: Array[CardData]) -> void:
	var count := cards_data.size()
	var viewport_center := get_viewport().get_visible_rect().get_center()
	var current_count := deck.get_child_count()

	for i in count:
		var c := card_scene.instantiate() as Card
		c.scale = Vector2.ZERO
		deck.add_child(c)
		c.position = viewport_center + Vector2(randf_range(-60, 60), randf_range(-50, 50))

		var target_pos := _get_deck_card_pos(current_count + i)
		if side == 1:
			c.show_cards = true
		c.setup(cards_data[i])

		var tween := create_tween()
		tween.tween_interval(i * 0.1)
		tween.tween_property(c, "position", target_pos, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(c, "scale", Vector2(0.6, 0.6), 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	var settle_time := (count - 1) * 0.1 + 0.5 + 0.2
	get_tree().create_timer(settle_time).timeout.connect(_rearrange_deck)


func _get_deck_card_pos(index: int) -> Vector2:
	var y := DECK_P2_Y if side == 2 else DECK_P1_Y
	return Vector2(DECK_START_X + index * DECK_SPACING, y)


func _rearrange_deck() -> void:
	for i in deck.get_child_count():
		var card := deck.get_child(i) as Control
		if card:
			var target_pos := _get_deck_card_pos(i)
			var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(card, "position", target_pos, 0.25)


func sync_deck_visual() -> void:
	var target := hand_manager.cards.size()
	while deck.get_child_count() > target:
		var last := deck.get_child(deck.get_child_count() - 1)
		deck.remove_child(last)
		last.queue_free()


func _hide_all_slots() -> void:
	for node in equip_nodes + field_nodes:
		node.visible = false


func place_equipment(card_data: CardData) -> void:
	for i in equip_slots.size():
		if equip_slots[i].is_empty():
			equip_slots[i] = {"card": card_data, "duration": card_data.duration}
			equip_nodes[i].visible = true
			return
	equip_slots[0] = {"card": card_data, "duration": card_data.duration}
	equip_nodes[0].visible = true


func place_field(card_data: CardData) -> void:
	for i in field_slots.size():
		if field_slots[i].is_empty():
			field_slots[i] = {"card": card_data, "duration": card_data.duration}
			field_nodes[i].visible = true
			return
	field_slots[0] = {"card": card_data, "duration": card_data.duration}
	field_nodes[0].visible = true


func tick_slot_durations() -> void:
	_tick_slots(equip_slots, equip_nodes)
	_tick_slots(field_slots, field_nodes)


func _tick_slots(slots: Array, nodes: Array) -> void:
	for i in slots.size():
		if slots[i].is_empty():
			continue
		var dur: int = slots[i]["duration"]
		if dur > 0:
			dur -= 1
			slots[i]["duration"] = dur
			if dur <= 0:
				slots[i].clear()
				nodes[i].visible = false


func discard_basic_cards() -> void:
	var kept: Array[CardData] = []
	for c in hand_manager.cards:
		if c.type in [CardData.CardType.NOTE, CardData.CardType.MISS, CardData.CardType.HEAL]:
			continue
		kept.append(c)
	hand_manager.cards = kept


func discard_non_basic_and_draw(draw_count: int) -> void:
	var kept: Array[CardData] = []
	for c in hand_manager.cards:
		if c.type in [CardData.CardType.EQUIPMENT, CardData.CardType.FIELD, CardData.CardType.EVENT]:
			continue
		kept.append(c)
	hand_manager.cards = kept
	var drawn := hand_manager.draw_from_deck(draw_count)
	if drawn.size() > 0:
		animate_draw(drawn)
