# CardExecutor.gd
# 卡牌打出时的校验与执行。作为 game 的子节点存在，通过 group 查找。
extends Node


func _ready() -> void:
	add_to_group("card_executor")
	SignalBus.card_play_requested.connect(_on_card_play_requested)
	SignalBus.card_sell_requested.connect(_on_card_sell_requested)


func _on_card_play_requested(card: Card) -> void:
	var player_id := _get_card_owner_id(card)
	if player_id == 0:
		return

	var tm := _get_turn_manager()
	if tm == null:
		return

	# 只有当前行动玩家才能出牌
	if player_id != tm.current_acting_player:
		return

	# 玩家已结束回合
	if tm.is_player_ended(player_id):
		return

	var data := card.card_data
	if data == null:
		return

	# 校验：是否有足够的硬币（含费用递增）
	var actual_cost := _calc_cost(player_id, data.cost)
	if not GameManager.spend_coins(player_id, actual_cost):
		print("硬币不足，需要 %d 硬币" % actual_cost)
		return
	if player_id == 1:
		CoinFlyManager.remove_coins_from_bar(actual_cost)

	# 从手牌数据中移除，空出位置给抽牌效果
	_remove_card_data_from_player(card, player_id)

	# 执行卡牌效果
	_execute_effect(player_id, data)

	# 从手牌视觉移除并同步 deck
	var hand_area := _get_player_hand_area(player_id)
	if hand_area:
		hand_area.remove_card(card)
		if hand_area._is_open:
			hand_area.close()
	_sync_player_deck(player_id)

	# 通知 TurnManager
	if data.type == CardData.CardType.MISS:
		tm.refund_action(player_id)
	tm.notify_action_done(player_id)


func _on_card_sell_requested(card: Card) -> void:
	var player_id := _get_card_owner_id(card)
	if player_id == 0:
		return

	var tm := _get_turn_manager()
	if tm == null:
		return

	if player_id != tm.current_acting_player:
		return

	GameManager.add_coins(player_id, 1)
	if player_id == 1:
		CoinFlyManager.add_coin_to_bar()
	_remove_card_from_hand(card, player_id)


func _calc_cost(player_id: int, base_cost: int) -> int:
	var tm := _get_turn_manager()
	if tm == null:
		return base_cost

	var actions_taken : int = tm.get_actions_taken(player_id)
	var escalate_from = 2 + tm.get_escalation_offset()
	if actions_taken < escalate_from:
		return base_cost
	var escalation : int = actions_taken - escalate_from + 1
	return base_cost + escalation


func _execute_effect(player_id: int, data: CardData) -> void:
	var target_id := 2 if player_id == 1 else 1

	match data.type:
		CardData.CardType.NOTE:
			var bonus := GameManager.get_combo_bonus(player_id)
			GameManager.deal_damage(target_id, data.damage_value + bonus, data)
			GameManager.add_combo(player_id)
		CardData.CardType.EQUIPMENT:
			_place_card(player_id, data, "equip")
		CardData.CardType.FIELD:
			_place_card(player_id, data, "field")
		CardData.CardType.HEAL:
			GameManager.heal_hp(player_id, data.damage_value)
		CardData.CardType.EVENT:
			_execute_event(player_id, data)
		CardData.CardType.MISS:
			pass


func _place_card(player_id: int, data: CardData, slot_type: String) -> void:
	var player := _get_player(player_id)
	if player == null:
		return
	if slot_type == "equip":
		player.place_equipment(data)
	else:
		player.place_field(data)


func _execute_event(player_id: int, data: CardData) -> void:
	match data.card_name:
		"羽绒服":
			GameManager.gain_shield(player_id, data.damage_value)
		"推分":
			_draw_cards(player_id, data.damage_value)
		"初见杀":
			var target_id := 2 if player_id == 1 else 1
			GameManager.modify_combo(target_id, -1)
		"今天手感爆炸":
			GameManager.modify_combo(player_id, 1)
		_:
			pass


func _draw_cards(player_id: int, count: int) -> void:
	var player := _get_player(player_id)
	if player == null:
		return
	var drawn := player.hand_manager.draw_from_deck(count)
	if drawn.size() > 0:
		player.animate_draw(drawn)


func _get_player(player_id: int) -> Player:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player and node.side == player_id:
			return node
	return null


func _remove_card_from_hand(card: Card, player_id: int) -> void:
	var hand_area := _get_player_hand_area(player_id)
	if hand_area:
		hand_area.remove_card(card)
	_remove_card_data_from_player(card, player_id)
	_sync_player_deck(player_id)
	if hand_area and hand_area._is_open:
		hand_area.close()


func _sync_player_deck(player_id: int) -> void:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player and node.side == player_id:
			node.sync_deck_visual()
			return


func _remove_card_data_from_player(card: Card, player_id: int) -> void:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player and node.side == player_id:
			node.hand_manager.remove_card(card.card_data)
			return


func _get_card_owner_id(card: Card) -> int:
	var node := card.get_parent()
	while node:
		if node is Player:
			return node.side
		node = node.get_parent()
	return 0


func _get_player_hand_area(player_id: int) -> HandArea:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player and node.side == player_id:
			return node.hand as HandArea
	return null


func _get_turn_manager() -> Node:
	return get_tree().get_first_node_in_group("turn_manager")
