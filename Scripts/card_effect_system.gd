class_name CardEffectSystem
extends Node

const BASE_DAMAGE := 5
const BASE_SHIELD := 4
const BUFF_DAMAGE := 2

var _attack_buffs: Dictionary = { 1: 0, 2: 0 }
var _summoned_units: Dictionary = { 1: [], 2: [] }


func _ready() -> void:
	add_to_group("card_effect")


func execute_card(card: Card, player_id: int) -> bool:
	if card == null or card.data == null:
		return false
	
	if not GameManager.spend_coins(card.data.cost):
		return false
	
	var target_id := 2 if player_id == 1 else 1
	
	match card.data.type:
		CardData.CardType.ATTACK:
			var damage = BASE_DAMAGE + _attack_buffs[player_id]
			GameManager.deal_damage(target_id, damage, card.data)
			_attack_buffs[player_id] = 0
		
		CardData.CardType.DEFENSE:
			GameManager.gain_shield(player_id, BASE_SHIELD)
		
		CardData.CardType.BUFF:
			_attack_buffs[player_id] += BUFF_DAMAGE
		
		CardData.CardType.SUMMON:
			_summon_unit(player_id)
	
	return true


func _on_action_ended(player_id: int) -> void:
	pass


func get_attack_buff(player_id: int) -> int:
	return _attack_buffs.get(player_id, 0)


func _summon_unit(player_id: int) -> void:
	var unit_count = _summoned_units[player_id].size()
	if unit_count < 3:
		_summoned_units[player_id].append({
			"atk": 3,
			"hp": 2
		})


func get_units(player_id: int) -> Array:
	return _summoned_units.get(player_id, [])


func reset() -> void:
	_attack_buffs = { 1: 0, 2: 0 }
	_summoned_units = { 1: [], 2: [] }
