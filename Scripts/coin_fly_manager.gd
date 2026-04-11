# CoinFlyManager.gd
extends Node

@export var coin_scene: PackedScene
@export var coin_bar: Panel   # 直接 export，让 Game.gd 在 _ready 里赋值

const FLY_DURATION   := 0.4
const SPAWN_INTERVAL := 0.04

var _canvas_layer: CanvasLayer

func _ready() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 10
	add_child(_canvas_layer)
func play_coin_fly(amount: int, from_pos: Vector2) -> void:
	for i in amount:
		await get_tree().create_timer(SPAWN_INTERVAL * i).timeout
		_spawn_one(from_pos)
	await get_tree().create_timer(FLY_DURATION + 0.1).timeout


func _spawn_one(from_pos: Vector2) -> void:
	# 飞行用的临时硬币图标
	var fly_coin = coin_scene.instantiate()
	_canvas_layer.add_child(fly_coin)

	var scatter := Vector2(randf_range(-40.0, 40.0), randf_range(-30.0, 30.0))
	fly_coin.global_position = from_pos + scatter

	# 终点：CoinBar 的位置（VBoxContainer 会从这里开始排列）
	var to_pos := coin_bar.global_position

	var tween := create_tween() \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUAD)

	tween.tween_property(fly_coin, "global_position", to_pos, FLY_DURATION)
	tween.tween_property(fly_coin, 'scale', Vector2.ZERO, FLY_DURATION)
	tween.tween_callback(func() -> void:
		fly_coin.queue_free()           # 飞行图标消失
		_add_coin_to_bar()              # 真正的 Coin 节点加入 CoinBar
		GameManager.coins += 1
	)


func _add_coin_to_bar() -> void:
	var coin = coin_scene.instantiate()
	coin.position = Vector2(coin.size.x/4, coin_bar.position.y - 15 + (coin.size.y+15) * (coin_bar.get_child_count(false)-1))
	coin_bar.add_child(coin)
	
	# 加入时做一个小弹出动画，避免硬币突然冒出来太生硬
	coin.scale = Vector2.ZERO
	var tween := create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)    # BACK 会有轻微过冲，像弹簧
	tween.tween_property(coin, "scale", Vector2.ONE, 0.2)
