# TurnManager.gd
extends Node

signal turn_started(turn_number: int)
signal coins_granted(amount: int)
signal cards_drawn(player_id: int, amount: int)
signal pre_settle_started
signal post_settle_started
signal action_started(player_id: int)
signal action_ended(player_id: int)
signal turn_ended(turn_number: int)
signal game_over(winner_id: int)
signal ready_to_start
signal ready_to_deal_coins
signal ready_to_deal_cards
signal ready_for_p1_action
signal ready_for_p2_action
signal ready_to_end

signal action_confirmed(player_id: int)

const COINS_PER_TURN  := 9
const CARDS_PER_TURN  := 3
const ACTIONS_PER_TURN := 2

var current_turn   : int  = 0
var first_player   : int  = 1
var _first_to_end  : int  = 0
var current_acting_player: int = 0
var _in_action_phase := false


func _ready() -> void:
	add_to_group("turn_manager")

# 每个玩家的行动剩余次数（无硬上限，手动结束回合）
var _actions_left  : Dictionary = { 1: ACTIONS_PER_TURN, 2: ACTIONS_PER_TURN }
var _max_actions   : Dictionary = { 1: ACTIONS_PER_TURN, 2: ACTIONS_PER_TURN }
# 玩家是否已手动结束回合
var _player_ended  : Dictionary = { 1: false, 2: false }


func get_actions_taken(player_id: int) -> int:
	return _max_actions.get(player_id, ACTIONS_PER_TURN) - _actions_left.get(player_id, 0)


func is_player_ended(player_id: int) -> bool:
	return _player_ended.get(player_id, false)


func refund_action(player_id: int) -> void:
	_actions_left[player_id] += 1


func is_in_action_phase() -> bool:
	return _in_action_phase


# ── 对外接口 ────────────────────────────────────

func start_game() -> void:
	#first_player = randi_range(1, 2)
	first_player = 1
	current_acting_player = first_player
	current_turn = 0
	_run_game()


# 玩家完成一次行动后调用（出牌/切换角色/释放技能）
func notify_action_done(player_id: int) -> void:
	print(player_id, "完成行动")
	if _actions_left[player_id] <= 0 or _player_ended[player_id]:
		return
	action_confirmed.emit(player_id)


# 玩家手动结束回合时调用
func notify_end_turn(player_id: int) -> void:
	print(player_id, "声明跳过")
	if _player_ended[player_id]:
		return
	if _first_to_end == 0:
		_first_to_end = player_id        # 记录先结束的人，下回合他是先手
	_player_ended[player_id] = true
	action_confirmed.emit(player_id)       # 让等待中的 await 继续走


# ── 主循环 ──────────────────────────────────────

func _run_game() -> void:
	while true:
		current_turn += 1
		await _phase_round_start()
		await _phase_deal_coins()
		await _phase_deal_cards()
		await _phase_pre_settle()
		if await _phase_actions():
			break
		await _phase_post_settle()
		await _phase_round_end()
		if await _phase_check_game_over():
			return
		_phase_swap_first_player()


func _phase_round_start() -> void:
	# 重置状态
	_player_ended  = { 1: false, 2: false }
	_first_to_end  = 0

	# 场地效果: 回合开始
	_foreach_field(func(_carrier: Player, card: CardData):
		match card.card_name:
			"夜勤":
				GameManager.gain_shield(1, 10)
				GameManager.gain_shield(2, 10)
	)

	# 效果触发后 tick 持续回合
	for pid in [1, 2]:
		var p := _get_player(pid)
		if p:
			p.tick_slot_durations()
	
	turn_started.emit(current_turn)
	await ready_to_start


func _phase_deal_coins() -> void:
	var second_player := 2 if first_player == 1 else 1
	CoinFlyManager.clear_bar()
	GameManager.add_coins(first_player, COINS_PER_TURN)
	GameManager.add_coins(second_player, COINS_PER_TURN)
	coins_granted.emit(COINS_PER_TURN)
	await ready_to_deal_coins

func _phase_deal_cards() -> void:
	var second_player := 2 if first_player == 1 else 1
	var bonus := 0
	_foreach_field(func(_carrier: Player, card: CardData):
		if card.card_name == "版本更新":
			bonus += 1
	)
	cards_drawn.emit(first_player, CARDS_PER_TURN + bonus)
	await ready_to_deal_cards
	cards_drawn.emit(second_player, CARDS_PER_TURN + bonus)
	await ready_to_deal_cards

func _phase_pre_settle() -> void:
	_foreach_field(func(carrier: Player, card: CardData):
		match card.card_name:
			"ttnk":
				carrier.discard_basic_cards()
			"熊谷凌":
				carrier.discard_non_basic_and_draw(1)
	)
	pre_settle_started.emit()
	await ready_to_start


func _phase_actions() -> bool:
	var second_player := 2 if first_player == 1 else 1
	_in_action_phase = true

	while _can_anyone_act():
		if await _do_player_actions(first_player):
			return true
		if await _do_player_actions(second_player):
			return true

	_in_action_phase = false
	return false


func _check_defeat() -> bool:
	if GameManager.is_player_defeated(1):
		game_over.emit(2)
		_in_action_phase = false
		return true
	if GameManager.is_player_defeated(2):
		game_over.emit(1)
		_in_action_phase = false
		return true
	return false


func _do_player_actions(player_id: int) -> bool:
	if _player_ended[player_id]:
		return false

	var max_actions := ACTIONS_PER_TURN
	var limit := _get_actions_limit()
	if limit > 0 and limit < max_actions:
		max_actions = limit
	_max_actions[player_id] = max_actions
	_actions_left[player_id] = max_actions

	current_acting_player = player_id
	action_started.emit(player_id)

	while _actions_left[player_id] > 0 and not _player_ended[player_id]:
		await action_confirmed
		if not _player_ended[player_id]:
			_actions_left[player_id] -= 1
		if _check_defeat():
			return true

	action_ended.emit(player_id)
	return false


func _phase_post_settle() -> void:
	post_settle_started.emit()
	await ready_to_end

func _phase_round_end() -> void:
	GameManager.clear_coins()
	turn_ended.emit(current_turn)
	await ready_to_end

func _phase_check_game_over() -> bool:
	if GameManager.is_player_defeated(1):
		game_over.emit(2)
		return true
	if GameManager.is_player_defeated(2):
		game_over.emit(1)
		return true
	return false


func _phase_swap_first_player() -> void:
	if _first_to_end != 0:
		first_player = _first_to_end     # 先结束的人下回合先手
	# 如果两人同时耗尽（没人手动结束），先手不变


# ── 工具 ────────────────────────────────────────

func _foreach_field(effect: Callable) -> void:
	for pid in [1, 2]:
		var p := _get_player(pid)
		if p == null:
			continue
		for slot in p.field_slots:
			if slot.is_empty():
				continue
			effect.call(p, slot["card"])


func _get_actions_limit() -> int:
	var limit := -1
	_foreach_field(func(_carrier: Player, card: CardData):
		if card.card_name == "大会模式":
			limit = 3
	)
	return limit


func get_escalation_offset() -> int:
	var offset := 0
	_foreach_field(func(_carrier: Player, card: CardData):
		match card.card_name:
			"精力充沛":
				offset += 1
			"精力不充沛":
				offset -= 1
	)
	return offset


func _get_player(pid: int) -> Player:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player and node.side == pid:
			return node
	return null

func _can_anyone_act() -> bool:
	for pid in [1, 2]:
		if not _player_ended[pid]:
			return true
	return false
