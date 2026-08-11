# Game.gd
extends Node

@onready var turn_manager      : Node        = $turn_manager
@onready var phase_banner      : CanvasLayer = $Top/phase_banner
@onready var overlay           : Panel       = $UI/overlay
@onready var coin_bar_p1       : Control       = $UI/Neutral/coin_bar
@onready var coin_bar_p2       : Control       = $UI/Neutral/coin_bar
@onready var UI                : CanvasLayer = $UI
@onready var player_scene      : PackedScene = preload("res://Scenes/player.tscn")


func _ready() -> void:
	_setup_card_executor()
	_setup_game()
	_connect_signals()

func _setup_game():
	_setup_player()

func _setup_card_executor():
	var ce := Node.new()
	ce.name = "card_executor"
	ce.set_script(preload("res://Scripts/card_executor.gd"))
	add_child(ce)

func _setup_player():
	var player1 = player_scene.instantiate()
	player1.side = 1
	player1.game = self
	var player2 = player_scene.instantiate()
	player2.side = 2
	player2.game = self
	player1.opponent = player2
	player2.opponent = player1
	UI.add_child(player1)
	UI.add_child(player2)
	_register_hp_bars()


func _register_hp_bars() -> void:
	var script := preload("res://Scripts/hp_bar.gd")
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player:
			for char_id in [1, 2]:
				var raw := node.get_node_or_null("Chara%d/hp_bar" % char_id)
				if raw:
					raw.set_script(script)
					raw.init()
					GameManager.register_hp_bar(node.side, char_id, raw)
				var streak := node.get_node_or_null("Chara%d/Streak" % char_id) as Label
				if streak:
					GameManager.register_streak_label(node.side, char_id, streak)

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
	var center := get_viewport().get_visible_rect().get_center()
	var p2_pos := Vector2(center.x, center.y - 300)
	var t1 := CoinFlyManager.play_coin_fly(amount, center, coin_bar_p1.global_position, true)
	var t2 := CoinFlyManager.play_coin_fly(amount, center, p2_pos, false)
	await t1.timeout
	await t2.timeout
	turn_manager.ready_to_deal_coins.emit()

func _on_cards_drawn(player_id: int, amount: int) -> void:
	var player := _get_player(player_id)
	var drawn_count := 0
	if player:
		var drawn_cards := player.hand_manager.draw_from_deck(amount)
		drawn_count = drawn_cards.size()
		if drawn_count > 0:
			player.animate_draw(drawn_cards)
	await phase_banner.show_phase("玩家 %d 抽 %d 张牌" % [player_id, drawn_count])
	if drawn_count > 0:
		await get_tree().create_timer(0.8).timeout
	turn_manager.ready_to_deal_cards.emit()


func _get_player(player_id: int) -> Player:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player and node.side == player_id:
			return node
	return null

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
	pass  # HPBar.set_shield handles the display via GameManager._update_shield_display


func _on_damage_dealt(target_player: int, amount: int, from_card: CardData) -> void:
	if amount > 0:
		_shake_screen()
		_flash_hp_bar(target_player)




func _shake_screen() -> void:
	var tween := create_tween()
	for i in 4:
		var offset := Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property(overlay, "position", offset, 0.05)
		tween.tween_property(overlay, "position", Vector2.ZERO, 0.05)


func _flash_hp_bar(player_id: int) -> void:
	var char_bars = GameManager.hp_bars.get(player_id, {})
	if char_bars.is_empty():
		return
	var char_id = GameManager.active_character.get(player_id, 1)
	var hp_bar = char_bars.get(char_id)
	if hp_bar:
		var original_modulate = hp_bar.modulate
		hp_bar.modulate = Color(1, 0.3, 0.3)
		get_tree().create_tween().tween_interval(0.15)
		hp_bar.modulate = original_modulate


func _on_game_over(winner_id: int) -> void:
	await overlay.fade_in(0.5)
	await phase_banner.show_phase("玩家 %d 获胜" % winner_id)



func _test() -> void:
	turn_manager.start_game()
