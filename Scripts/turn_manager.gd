# TurnManager.gd
extends Node

signal turn_started(turn_number: int)
signal coins_granted(amount: int)
signal cards_drawn(amount: int)
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

const COINS_PER_TURN  := 10
const CARDS_PER_TURN  := 4
const ACTIONS_PER_TURN := 2

var current_turn   : int  = 0
var first_player   : int  = 1        # 1 或 2，本回合先手
var _first_to_end  : int  = 0        # 第一个手动结束的玩家，0 = 还没人结束
var current_acting_player: int = 0

# 每个玩家的行动剩余次数
var _actions_left  : Dictionary = { 1: ACTIONS_PER_TURN, 2: ACTIONS_PER_TURN }
# 玩家是否已手动结束回合
var _player_ended  : Dictionary = { 1: false, 2: false }
# 等待玩家完成单次行动的信号
var _action_done   : Dictionary = { 1: false, 2: false }


# ── 对外接口 ────────────────────────────────────

func start_game() -> void:
	first_player = randi_range(1, 2)
	current_acting_player = first_player
	current_turn = 0
	_run_game()


# 玩家完成一次行动后调用（出牌/切换角色/释放技能）
func notify_action_done(player_id: int) -> void:
	print(player_id, "完成行动")
	if _actions_left[player_id] <= 0 or _player_ended[player_id]:
		return
	_action_done[player_id] = true


# 玩家手动结束回合时调用
func notify_end_turn(player_id: int) -> void:
	print(player_id, "声明跳过")
	if _player_ended[player_id]:
		return
	if _first_to_end == 0:
		_first_to_end = player_id        # 记录先结束的人，下回合他是先手
	_player_ended[player_id] = true
	_action_done[player_id] = true       # 让等待中的 await 继续走


# ── 主循环 ──────────────────────────────────────

func _run_game() -> void:
	while true:
		current_turn += 1
		await _phase_round_start()
		await _phase_deal_coins()
		await _phase_deal_cards()
		await _phase_pre_settle()
		await _phase_actions()
		await _phase_post_settle()
		await _phase_round_end()
		if await _phase_check_game_over():
			return
		_phase_swap_first_player()


func _phase_round_start() -> void:
	# 重置状态
	_actions_left  = { 1: ACTIONS_PER_TURN, 2: ACTIONS_PER_TURN }
	_player_ended  = { 1: false, 2: false }
	_action_done   = { 1: false, 2: false }
	_first_to_end  = 0
	
	turn_started.emit(current_turn)
	await ready_to_start


func _phase_deal_coins() -> void:
	coins_granted.emit(COINS_PER_TURN)
	await ready_to_deal_coins

func _phase_deal_cards() -> void:
	cards_drawn.emit(CARDS_PER_TURN)
	await ready_to_deal_cards

func _phase_pre_settle() -> void:
	pre_settle_started.emit()
	await ready_to_start


func _phase_actions() -> void:
	var second_player := 2 if first_player == 1 else 1

	# 只要还有人能行动就继续循环
	while _can_anyone_act():
		await _do_action(first_player)
		await _do_action(second_player)


func _do_action(player_id: int) -> void:
	# 该玩家已结束或耗尽行动次数，直接跳过
	if _player_ended[player_id] or _actions_left[player_id] <= 0:
		return
	current_acting_player = player_id
	_action_done[player_id] = false
	action_started.emit(player_id)

	# 等待玩家完成一次行动（出牌/切角色/技能）或手动结束
	while not _action_done[player_id]:
		await get_tree().process_frame

	if not _player_ended[player_id]:
		_actions_left[player_id] -= 1
		action_ended.emit(player_id)
		# 立即结算这次行动的效果（由结算系统监听 action_ended 处理）


func _phase_post_settle() -> void:
	post_settle_started.emit()
	await ready_to_end

func _phase_round_end() -> void:
	turn_ended.emit(current_turn)
	await ready_to_end

func _phase_check_game_over() -> bool:
	# 由 GameManager 维护血量，这里查询
	if GameManager.hp[1] <= 0:
		game_over.emit(2)
		return true
	if GameManager.hp[2] <= 0:
		game_over.emit(1)
		return true
	return false


func _phase_swap_first_player() -> void:
	if _first_to_end != 0:
		first_player = _first_to_end     # 先结束的人下回合先手
	# 如果两人同时耗尽（没人手动结束），先手不变


# ── 工具 ────────────────────────────────────────

func _can_anyone_act() -> bool:
	for pid in [1, 2]:
		if not _player_ended[pid] and _actions_left[pid] > 0:
			return true
	return false
