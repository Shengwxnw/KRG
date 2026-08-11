# CardData.gd
class_name CardData
extends Resource

enum CardType { NOTE, MISS, EQUIPMENT, HEAL, FIELD, EVENT }

enum NoteAttribute { TAP, HOLD, SLIDE, TOUCH, BREAK }

@export var card_name    : String        = ""
@export var cost         : int           = 1
@export var type         : CardType      = CardType.NOTE
@export var attribute    : NoteAttribute = NoteAttribute.TAP
@export var damage_value : int           = 0
@export var description  : String        = ""
@export var art          : Texture2D     = null
@export var duration     : int           = 0


static func _make(name: String, cost: int, ctype: CardType, attr: NoteAttribute, dmg: int, desc: String, dur: int = 0) -> CardData:
	var d := CardData.new()
	d.card_name = name
	d.cost = cost
	d.type = ctype
	d.attribute = attr
	d.damage_value = dmg
	d.description = desc
	d.duration = dur
	return d


static func make_full_deck() -> Array[CardData]:
	var d := NoteAttribute.TAP  # default placeholder
	var deck : Array[CardData] = []

	# ═══ Notes (属性牌) ═══
	for _i in 5:  deck.append(_make("Tap Note",  2, CardType.NOTE, NoteAttribute.TAP,   15, "造成15 TAP属性伤害"))
	for _i in 4:  deck.append(_make("Tap Note",  3, CardType.NOTE, NoteAttribute.TAP,   20, "造成20 TAP属性伤害"))
	for _i in 5:  deck.append(_make("Hold Note", 2, CardType.NOTE, NoteAttribute.HOLD,  15, "造成15 HOLD属性伤害"))
	for _i in 4:  deck.append(_make("Hold Note", 3, CardType.NOTE, NoteAttribute.HOLD,  20, "造成20 HOLD属性伤害"))
	for _i in 5:  deck.append(_make("Slide Note",2, CardType.NOTE, NoteAttribute.SLIDE, 15, "造成15 SLIDE属性伤害"))
	for _i in 4:  deck.append(_make("Slide Note",3, CardType.NOTE, NoteAttribute.SLIDE, 20, "造成20 SLIDE属性伤害"))
	for _i in 5:  deck.append(_make("Touch Note",2, CardType.NOTE, NoteAttribute.TOUCH, 15, "造成15 TOUCH属性伤害"))
	for _i in 4:  deck.append(_make("Touch Note",3, CardType.NOTE, NoteAttribute.TOUCH, 20, "造成20 TOUCH属性伤害"))
	for _i in 8:  deck.append(_make("Break Note",3, CardType.NOTE, NoteAttribute.BREAK, 20, "造成20 BREAK属性伤害"))

	# ═══ Misses (闪避牌) ═══
	for _i in 6:  deck.append(_make("Tap Miss",   3, CardType.MISS, NoteAttribute.TAP,   0, "闪避TAP指定伤害"))
	for _i in 6:  deck.append(_make("Hold Miss",  3, CardType.MISS, NoteAttribute.HOLD,  0, "闪避HOLD指定伤害"))
	for _i in 6:  deck.append(_make("Slide Miss", 3, CardType.MISS, NoteAttribute.SLIDE, 0, "闪避SLIDE指定伤害"))
	for _i in 6:  deck.append(_make("Touch Miss", 3, CardType.MISS, NoteAttribute.TOUCH, 0, "闪避TOUCH指定伤害"))
	for _i in 5:  deck.append(_make("Break Miss", 3, CardType.MISS, NoteAttribute.BREAK, 0, "闪避BREAK指定伤害"))

	# ═══ Heals (回复牌) ═══
	for _i in 6:  deck.append(_make("运动饮料", 3, CardType.HEAL, d, 15, "回复15 HP"))
	for _i in 6:  deck.append(_make("运动饮料", 4, CardType.HEAL, d, 20, "回复20 HP"))

	# ═══ Equipment (装备牌) ═══
	deck.append(_make("崭新的手套",   4, CardType.EQUIPMENT, d, 0, "第三阶段多获2牌", 2))
	deck.append(_make("崭新的手套",   4, CardType.EQUIPMENT, d, 0, "第三阶段多获2牌", 2))
	deck.append(_make("破旧的手套",   2, CardType.EQUIPMENT, d, 0, "第三阶段多获1牌", 1))
	deck.append(_make("破旧的手套",   2, CardType.EQUIPMENT, d, 0, "第三阶段多获1牌", 1))
	deck.append(_make("银行卡",       4, CardType.EQUIPMENT, d, 0, "第二阶段游戏币+1，第五回合后+2", 4))
	deck.append(_make("银行卡",       4, CardType.EQUIPMENT, d, 0, "第二阶段游戏币+1，第五回合后+2", 4))
	deck.append(_make("手机",         5, CardType.EQUIPMENT, d, 0, "每回合一次偷看对方手牌2张", -1))
	deck.append(_make("手机",         5, CardType.EQUIPMENT, d, 0, "每回合一次偷看对方手牌2张", -1))
	deck.append(_make("大水",         4, CardType.EQUIPMENT, d, 0, "受伤后回复伤害25%的HP", 4))
	deck.append(_make("大水",         4, CardType.EQUIPMENT, d, 0, "受伤后回复伤害25%的HP", 4))
	deck.append(_make("币框",         3, CardType.EQUIPMENT, d, 0, "剩余游戏币/2留到下一回合，最多3个", -1))
	deck.append(_make("币框",         3, CardType.EQUIPMENT, d, 0, "剩余游戏币/2留到下一回合，最多3个", -1))
	deck.append(_make("制谱器",       5, CardType.EQUIPMENT, d, 0, "每回合两次跳过本回合状态", 2))
	deck.append(_make("制谱器",       5, CardType.EQUIPMENT, d, 0, "每回合两次跳过本回合状态", 2))
	deck.append(_make("迪拉熊玩偶",   6, CardType.EQUIPMENT, d, 0, "转移50%伤害给玩偶(30HP)", -1))
	deck.append(_make("迪拉熊玩偶",   6, CardType.EQUIPMENT, d, 0, "转移50%伤害给玩偶(30HP)", -1))

	# ═══ Field (场地牌) ═══
	deck.append(_make("夜勤",         3, CardType.FIELD, d, 0, "回合开始时获得10护盾", 2))
	deck.append(_make("夜勤",         3, CardType.FIELD, d, 0, "回合开始时获得10护盾", 2))
	deck.append(_make("版本更新",     3, CardType.FIELD, d, 0, "第三阶段手牌+1", 2))
	deck.append(_make("版本更新",     3, CardType.FIELD, d, 0, "第三阶段手牌+1", 2))
	deck.append(_make("霸机",         6, CardType.FIELD, d, 0, "打出连击后多行动一次", 2))
	deck.append(_make("精力充沛",     3, CardType.FIELD, d, 0, "行动增费机制-1", 2))
	deck.append(_make("精力充沛",     3, CardType.FIELD, d, 0, "行动增费机制-1", 2))
	deck.append(_make("小卖部",       1, CardType.FIELD, d, 0, "翻牌堆前5张选择买入", 2))
	deck.append(_make("小卖部",       1, CardType.FIELD, d, 0, "翻牌堆前5张选择买入", 2))
	deck.append(_make("ttnk",         0, CardType.FIELD, d, 0, "弃置所有基本牌", 1))
	deck.append(_make("ttnk",         0, CardType.FIELD, d, 0, "弃置所有基本牌", 1))
	deck.append(_make("熊谷凌",       0, CardType.FIELD, d, 0, "弃置所有非基本牌，摸一张牌", 1))
	deck.append(_make("熊谷凌",       0, CardType.FIELD, d, 0, "弃置所有非基本牌，摸一张牌", 1))
	deck.append(_make("土豆服务器",   6, CardType.FIELD, d, 0, "所有Note和Miss失去属性", 1))
	deck.append(_make("大会模式",     0, CardType.FIELD, d, 0, "玩家只能行动三次", 2))
	deck.append(_make("大会模式",     0, CardType.FIELD, d, 0, "玩家只能行动三次", 2))
	deck.append(_make("精力不充沛",   2, CardType.FIELD, d, 0, "行动增费提前1次行动", 2))

	# ═══ Event (事件牌) ═══
	for _i in 8:  deck.append(_make("拆机小孩",       3, CardType.EVENT, d, 0, "拆掉任意一个对方的装备"))
	for _i in 8:  deck.append(_make("闭店",           3, CardType.EVENT, d, 0, "拆掉任意一个场地牌"))
	for _i in 6:  deck.append(_make("看起来很万能的牌",3, CardType.EVENT, d, 0, "无效任意一个事件牌"))
	for _i in 6:  deck.append(_make("推分",           3, CardType.EVENT, d, 2, "摸两张牌"))
	deck.append(_make("初见杀",         3, CardType.EVENT, d, 0, "给对方减少1层连击标记"))
	deck.append(_make("初见杀",         3, CardType.EVENT, d, 0, "给对方减少1层连击标记"))
	deck.append(_make("今天手感爆炸",   3, CardType.EVENT, d, 0, "给我方增加1层连击标记"))
	deck.append(_make("今天手感爆炸",   3, CardType.EVENT, d, 0, "给我方增加1层连击标记"))
	for _i in 3:  deck.append(_make("羽绒服",         3, CardType.EVENT, d, 15, "获得15护盾"))

	return deck
