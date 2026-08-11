extends CanvasLayer

func _ready() -> void:
	randomize()
	game_start()

const COINS_PER_TURN := 9
const MAX_HP := 50

var hp: Dictionary = {
	1: {1: MAX_HP, 2: MAX_HP},
	2: {1: MAX_HP, 2: MAX_HP}
}

var shield: Dictionary = {
	1: 0,
	2: 0
}

var active_character: Dictionary = {
	1: 1,
	2: 1
}

var player1
var player2
var coins: Dictionary = {
	1: 0,
	2: 0
}

var hp_bars: Dictionary = {}
var streak_labels: Dictionary = {}

var combo: Dictionary = {
	1: {1: 0, 2: 0},
	2: {1: 0, 2: 0}
}

const COMBO_MAX  := 4
const COMBO_PER  := 4

signal coin_changed(player_id: int, amount: int)
signal damage_dealt(target_player: int, amount: int, from_card: CardData)
signal shield_changed(player_id: int, amount: int)
signal hp_changed(player_id: int, char_id: int, new_hp: int)
signal active_character_changed(player_id: int, new_char: int)
signal combo_changed(player_id: int, char_id: int, new_combo: int)


func game_start() -> void:
	pass


func register_hp_bar(player_id: int, char_id: int, node: Control) -> void:
	if not hp_bars.has(player_id):
		hp_bars[player_id] = {}
	hp_bars[player_id][char_id] = node
	node.max_hp = MAX_HP
	node.set_hp(hp[player_id][char_id])


func get_hp(player_id: int, char_id: int = -1) -> int:
	if char_id < 0:
		char_id = active_character.get(player_id, 1)
	return hp.get(player_id, {}).get(char_id, 0)


func is_player_defeated(player_id: int) -> bool:
	return hp[player_id][1] <= 0 and hp[player_id][2] <= 0


func switch_active_character(player_id: int) -> void:
	var current: int = active_character.get(player_id, 1)
	var other: int = 3 - current
	active_character[player_id] = other
	_update_hp_bar(player_id)
	_update_shield_display(player_id)
	active_character_changed.emit(player_id, other)


func deal_damage(target_player: int, amount: int, from_card: CardData = null, is_true_damage: bool = false) -> int:
	if target_player < 1 or target_player > 2:
		return 0
	if amount <= 0:
		return 0

	var char_id: int = active_character.get(target_player, 1)
	if not hp[target_player].has(char_id):
		return 0

	var shield_absorbed := 0
	var damage_to_hp := amount

	if not is_true_damage:
		var shield_remaining: int = shield[target_player]
		if shield_remaining > 0:
			if shield_remaining >= amount:
				shield[target_player] -= amount
				shield_absorbed = amount
				damage_to_hp = 0
			else:
				shield_absorbed = shield_remaining
				damage_to_hp = amount - shield_remaining
				shield[target_player] = 0
			shield_changed.emit(target_player, shield[target_player])

	if damage_to_hp > 0:
		hp[target_player][char_id] = maxi(0, hp[target_player][char_id] - damage_to_hp)
		hp_changed.emit(target_player, char_id, hp[target_player][char_id])

	_update_hp_bar(target_player)
	_update_shield_display(target_player)
	damage_dealt.emit(target_player, damage_to_hp, from_card)

	if hp[target_player][char_id] <= 0:
		var other: int = 3 - char_id
		if hp[target_player].has(other) and hp[target_player][other] > 0:
			switch_active_character(target_player)

	return damage_to_hp


func gain_shield(player_id: int, amount: int) -> void:
	if player_id < 1 or player_id > 2:
		return
	shield[player_id] += amount
	shield_changed.emit(player_id, shield[player_id])
	_update_shield_display(player_id)


func heal_hp(player_id: int, amount: int) -> void:
	if player_id < 1 or player_id > 2:
		return
	var char_id : int = active_character.get(player_id, 1)
	hp[player_id][char_id] = mini(hp[player_id][char_id] + amount, MAX_HP)
	hp_changed.emit(player_id, char_id, hp[player_id][char_id])
	_update_hp_bar(player_id)


func _update_hp_bar(player_id: int) -> void:
	var char_id = active_character.get(player_id, 1)
	if hp_bars.has(player_id) and hp_bars[player_id].has(char_id):
		hp_bars[player_id][char_id].set_hp(hp[player_id][char_id])


func _update_shield_display(player_id: int) -> void:
	var char_id = active_character.get(player_id, 1)
	if hp_bars.has(player_id) and hp_bars[player_id].has(char_id):
		hp_bars[player_id][char_id].set_shield(shield[player_id])


func add_coins(player_id: int, amount: int) -> void:
	if player_id < 1 or player_id > 2:
		return
	coins[player_id] += amount
	coin_changed.emit(player_id, coins[player_id])


func spend_coins(player_id: int, amount: int) -> bool:
	if player_id < 1 or player_id > 2:
		return false
	if coins[player_id] >= amount:
		coins[player_id] -= amount
		coin_changed.emit(player_id, coins[player_id])
		return true
	return false


func clear_coins() -> void:
	for pid in [1, 2]:
		coins[pid] = 0
		coin_changed.emit(pid, 0)


func get_shield(player_id: int) -> int:
	return shield.get(player_id, 0)


func register_streak_label(player_id: int, char_id: int, node: Label) -> void:
	if not streak_labels.has(player_id):
		streak_labels[player_id] = {}
	streak_labels[player_id][char_id] = node
	_update_streak_label(player_id, char_id)


func _update_streak_label(player_id: int, char_id: int) -> void:
	if streak_labels.has(player_id) and streak_labels[player_id].has(char_id):
		var c = combo[player_id][char_id]
		streak_labels[player_id][char_id].text = "×%d" % c if c > 0 else ""


func add_combo(player_id: int) -> int:
	var char_id = active_character.get(player_id, 1)
	if combo[player_id][char_id] < COMBO_MAX:
		combo[player_id][char_id] += 1
		combo_changed.emit(player_id, char_id, combo[player_id][char_id])
		_update_streak_label(player_id, char_id)
	return combo[player_id][char_id]


func reset_combo(player_id: int) -> void:
	var char_id = active_character.get(player_id, 1)
	if combo[player_id][char_id] > 0:
		combo[player_id][char_id] = 0
		combo_changed.emit(player_id, char_id, 0)
		_update_streak_label(player_id, char_id)


func modify_combo(player_id: int, delta: int) -> void:
	if delta > 0:
		for _i in abs(delta):
			add_combo(player_id)
	else:
		var char_id = active_character.get(player_id, 1)
		combo[player_id][char_id] = maxi(0, combo[player_id][char_id] + delta)
		combo_changed.emit(player_id, char_id, combo[player_id][char_id])
		_update_streak_label(player_id, char_id)


func get_combo_bonus(player_id: int) -> int:
	var char_id = active_character.get(player_id, 1)
	return combo[player_id][char_id] * COMBO_PER
