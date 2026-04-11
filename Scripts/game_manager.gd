extends CanvasLayer

func _ready() -> void:
	randomize()
	game_start()

const COINS_PER_TURN := 10
const MAX_HP := 10

var hp: Dictionary = {
	1: MAX_HP, 
	2: MAX_HP
}

var shield: Dictionary = {
	1: 0,
	2: 0
}

var player1
var player2
var coins: int = 0:
	set(value):
		coins = value
		coin_changed.emit(coins)

var hp_bars: Dictionary = {}

func game_start() -> void:
	pass


func deal_damage(target_player: int, amount: int, from_card: CardData = null) -> int:
	if target_player < 1 or target_player > 2:
		return 0
	
	var shield_remaining = shield[target_player]
	var damage_to_hp := amount
	
	if shield_remaining > 0:
		if shield_remaining >= amount:
			shield[target_player] -= amount
			damage_to_hp = 0
		else:
			damage_to_hp = amount - shield_remaining
			shield[target_player] = 0
	
	if damage_to_hp > 0:
		hp[target_player] = maxi(0, hp[target_player] - damage_to_hp)
	
	_update_hp_bar(target_player)
	damage_dealt.emit(target_player, damage_to_hp, from_card)
	
	return damage_to_hp


func gain_shield(player_id: int, amount: int) -> void:
	if player_id < 1 or player_id > 2:
		return
	shield[player_id] += amount
	shield_changed.emit(player_id, shield[player_id])


func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false


func get_shield(player_id: int) -> int:
	return shield.get(player_id, 0)


func register_hp_bar(player_id: int, hp_bar: HPBar) -> void:
	hp_bars[player_id] = hp_bar
	hp_bar.max_hp = MAX_HP
	hp_bar._current_hp = hp[player_id]
	hp_bar._displayed_hp = hp[player_id]


func _update_hp_bar(player_id: int) -> void:
	if hp_bars.has(player_id):
		hp_bars[player_id]._current_hp = hp[player_id]
		hp_bars[player_id]._hp_changed()


signal coin_changed(new_amount: int)
signal damage_dealt(target_player: int, amount: int, from_card: CardData)
signal shield_changed(player_id: int, amount: int)
