# CardData.gd
class_name CardData
extends Resource

enum CardType { ATTACK, DEFENSE, BUFF, SUMMON }

@export var card_name   : String      = ""
@export var cost        : int         = 1
@export var type        : CardType    = CardType.ATTACK
@export var description : String      = ""
@export var art         : Texture2D   = null

# CardData.gd 底部加一个静态方法，方便测试
static func make_test_deck() -> Array[CardData]:
	var deck : Array[CardData] = []

	var cards := [
		["直拳",   1, CardType.ATTACK,  "造成 5 点伤害"],
		["格挡",   1, CardType.DEFENSE, "获得 4 点护盾"],
		["蓄力",   1, CardType.BUFF,    "下次攻击 +2 伤害"],
		["召唤石像", 3, CardType.SUMMON, "召唤一个随从"],
	]

	for c in cards:
		var data        = CardData.new()
		data.card_name  = c[0]
		data.cost       = c[1]
		data.type       = c[2]
		data.description = c[3]
		deck.append(data)

	return deck
