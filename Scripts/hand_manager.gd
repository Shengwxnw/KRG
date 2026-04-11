# HandManager.gd
extends Node

@export var deck_pile  : DeckPile
@export var hand_area  : HandArea
@export var overlay    : Panel
@export var player_id  : int = 1

var _hand      : Array[CardData] = []
var _in_battle : bool = false
var _card_effect_system: CardEffectSystem


func setup(deck: Array[CardData]) -> void:
	deck_pile.setup(deck)
	deck_pile.deck_clicked.connect(_on_deck_clicked)
	hand_area.closed.connect(_on_hand_closed)
	hand_area.card_played.connect(_on_card_played)


func set_battle_mode(active: bool) -> void:
	_in_battle = active


func draw_cards(amount: int) -> void:
	var deck := deck_pile.get_cards()
	for i in min(amount, deck.size()):
		_hand.append(deck[i])
	# 后续从牌堆移除已摸的牌


# ── 事件 ────────────────────────────────────────

func _on_deck_clicked() -> void:
	if _in_battle:
		_open_hand()
	else:
		pass   # 回合外 → 后续做详情界面


func _open_hand() -> void:
	await overlay.fade_in(0.25)
	await hand_area.open(_hand)


func _on_hand_closed() -> void:
	await overlay.fade_out(0.25)


func _on_card_played(card: Card) -> void:
	for i in _hand.size():
		if _hand[i] == card.data:
			_hand.remove_at(i)
			break
	
	if _card_effect_system == null:
		_card_effect_system = get_tree().get_first_node_in_group("card_effect") as CardEffectSystem
	
	if _card_effect_system:
		_card_effect_system.execute_card(card, player_id)
	
	TurnManager.notify_action_done(player_id)
