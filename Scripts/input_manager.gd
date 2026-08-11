extends Node

var _open_hand_area: HandArea = null


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_handle_mouse(event)

	var tm := _get_turn_manager()
	if tm == null:
		return

	if event.is_action_pressed("ui_accept"):
		_handle_accept(tm)
	if event.is_action_pressed("ui_cancel"):
		tm.notify_end_turn(tm.current_acting_player)
	if event.is_action_pressed("deal_damage"):
		_deal_test_damage(tm)


func _handle_mouse(event: InputEventMouseButton) -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var w := vp_size.x
	var h := vp_size.y
	var pos = event.position

	if SignalBus.is_side_bar_open:
		if pos.x < w * 3.0 / 4.0:
			SignalBus.close_side_bar.emit()
	elif _open_hand_area != null and is_instance_valid(_open_hand_area):
		if pos.y < h / 2.0:
			_open_hand_area.close()
			_open_hand_area = null


func _handle_accept(tm: Node) -> void:
	if tm.current_acting_player == 2:
		var p1 : int = 3 - tm.current_acting_player
		if tm.is_player_ended(p1):
			tm.notify_end_turn(tm.current_acting_player)
		else:
			tm.notify_action_done(tm.current_acting_player)
	else:
		tm.notify_action_done(tm.current_acting_player)


func _deal_test_damage(tm: Node) -> void:
	var player_id: int = tm.current_acting_player
	var target_id := 2 if player_id == 1 else 1
	GameManager.deal_damage(target_id, randi_range(1, 10))
	tm.notify_action_done(player_id)


func _get_turn_manager() -> Node:
	return get_tree().get_first_node_in_group("turn_manager")


func register_open_hand(hand: HandArea) -> void:
	_open_hand_area = hand


func unregister_open_hand(hand: HandArea) -> void:
	if _open_hand_area == hand:
		_open_hand_area = null
