# Game.gd
extends Node

@onready var turn_manager     : Node        = $turn_manager
@onready var phase_banner      : CanvasLayer = $phase_banner
@onready var overlay           : Panel       = $overlay
@onready var coin_bar_p1       : Panel       = $UI/Neutral/coin_holder
@onready var coin_bar_p2       : Panel       = $UI/Neutral/coin_holder
@onready var card_effect_system: Node        = $card_effect_system


func _ready() -> void:
	_connect_signals()
	_setup_hp_bars()
	turn_manager.start_game()


func _setup_hp_bars() -> void:
	var hp_bar_p1 = $UI/hp_bar_p1 as HPBar
	var hp_bar_p2 = $UI/hp_bar_p2 as HPBar
	if hp_bar_p1:
		GameManager.register_hp_bar(1, hp_bar_p1)
	if hp_bar_p2:
		GameManager.register_hp_bar(2, hp_bar_p2)


func _connect_signals() -> void:
	CoinFlyManager.coin_bar = coin_bar_p1
	CoinFlyManager.coin_scene = preload("res://Scenes/coin.tscn")

	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.coins_granted.connect(_on_coins_granted)
	turn_manager.cards_drawn.connect(_on_cards_drawn)
	turn_manager.pre_settle_started.connect(_on_pre_settle)
	turn_manager.action_started.connect(_on_action_started)
	turn_manager.post_settle_started.connect(_on_post_settle)
	turn_manager.turn_ended.connect(_on_turn_ended)
	turn_manager.game_over.connect(_on_game_over)
	GameManager.shield_changed.connect(_on_shield_changed)
	GameManager.damage_dealt.connect(_on_damage_dealt)


# ── 回合事件 ────────────────────────────────────

func _on_turn_started(turn_number: int) -> void:
	await phase_banner.show_phase("第 %d 回合" % turn_number)
	turn_manager.ready_to_start.emit()


func _on_coins_granted(amount: int) -> void:
	await phase_banner.show_phase("发币")
	var from_pos := get_viewport().get_visible_rect().get_center()
	await CoinFlyManager.play_coin_fly(amount, from_pos)
	turn_manager.ready_to_deal_coins.emit()

func _on_cards_drawn(_amount: int) -> void:
	await phase_banner.show_phase("发牌")
	# 后续接 HandManager
	turn_manager.ready_to_deal_cards.emit()

func _on_pre_settle() -> void:
	await phase_banner.show_phase("先行结算")
	turn_manager.ready_to_start.emit()


func _on_action_started(player_id: int) -> void:
	await phase_banner.show_phase("玩家 %d 行动" % player_id)


func _on_post_settle() -> void:
	await phase_banner.show_phase("后行结算")
	turn_manager.ready_to_end.emit()


func _on_turn_ended(turn_number: int) -> void:
	await phase_banner.show_phase("第 %d 回合结束" % turn_number)
	turn_manager.ready_to_end.emit()


func _on_shield_changed(player_id: int, amount: int) -> void:
	if GameManager.hp_bars.has(player_id):
		GameManager.hp_bars[player_id].set_shield(amount)


func _on_damage_dealt(target_player: int, amount: int, from_card: CardData) -> void:
	if amount > 0:
		_shake_screen()
		_flash_hp_bar(target_player)


func _shake_screen() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		cam = get_parent().get_node_or_null("Camera2D") as Node2D
	
	var original_pos := Vector2.ZERO
	var tween := create_tween()
	for i in 4:
		var offset := Vector2(randf_range(-8, 8), randf_range(-8, 8))
		tween.tween_property(self, "position", original_pos + offset, 0.05)
		tween.tween_property(self, "position", original_pos, 0.05)
	tween.tween_callback(_end_shake)


func _end_shake() -> void:
	coin_bar_p1.position = Vector2.ZERO


func _flash_hp_bar(player_id: int) -> void:
	if GameManager.hp_bars.has(player_id):
		var hp_bar = GameManager.hp_bars[player_id]
		var original_modulate = hp_bar.modulate
		hp_bar.modulate = Color(1, 0.3, 0.3, 1)
		await get_tree().create_timer(0.15).timeout
		hp_bar.modulate = original_modulate


func _on_game_over(winner_id: int) -> void:
	await overlay.fade_in(0.5)
	await phase_banner.show_phase("玩家 %d 获胜" % winner_id)


# ── 玩家输入（暂时用键盘测试）────────────────────

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):   # 空格/Enter = 结束行动
		turn_manager.notify_action_done(turn_manager.current_acting_player)
	if event.is_action_pressed("ui_cancel"):   # Esc = 结束回合
		turn_manager.notify_end_turn(turn_manager.current_acting_player)
