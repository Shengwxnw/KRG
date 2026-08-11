# HandManager.gd
# 管理玩家的手牌数据（上限、抽牌、弃牌、打出）
class_name HandManager
extends Node

const MAX_HAND_SIZE := 9

var cards: Array[CardData] = []
var deck : Array[CardData] = []


func draw_card(card: CardData) -> bool:
	if cards.size() >= MAX_HAND_SIZE:
		return false
	cards.append(card)
	return true


func draw_cards(card_list: Array[CardData]) -> int:
	var drawn := 0
	for c in card_list:
		if draw_card(c):
			drawn += 1
		else:
			break
	return drawn


func draw_from_deck(count: int) -> Array[CardData]:
	var drawn_cards: Array[CardData] = []
	for _i in count:
		if deck.is_empty() or is_hand_full():
			break
		var card : CardData = deck.pop_front()
		cards.append(card)
		drawn_cards.append(card)
	return drawn_cards


func remove_card(card_data: CardData) -> bool:
	var idx := cards.find(card_data)
	if idx != -1:
		cards.remove_at(idx)
		return true
	return false


func is_hand_full() -> bool:
	return cards.size() >= MAX_HAND_SIZE


func hand_size() -> int:
	return cards.size()
