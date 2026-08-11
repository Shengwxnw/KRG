# CoinFlyManager.gd
extends Node

@export var coin_scene: PackedScene
@export var coin_bar: Control

const FLY_DURATION   := 0.4
const SPAWN_INTERVAL := 0.04

var _canvas_layer: CanvasLayer


func _ready() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 10
	add_child(_canvas_layer)


func play_coin_fly(amount: int, from_pos: Vector2, to_pos: Vector2, add_to_bar: bool) -> SceneTreeTimer:
	for i in amount:
		get_tree().create_timer(SPAWN_INTERVAL * i).timeout.connect(
			func(): _spawn_one(from_pos, to_pos, add_to_bar)
		)
	return get_tree().create_timer(SPAWN_INTERVAL * amount + FLY_DURATION + 0.1)


func _spawn_one(from_pos: Vector2, to_pos: Vector2, add_to_bar: bool) -> void:
	var fly_coin = coin_scene.instantiate()
	_canvas_layer.add_child(fly_coin)

	var scatter := Vector2(randf_range(-40.0, 40.0), randf_range(-30.0, 30.0))
	fly_coin.global_position = from_pos + scatter

	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(fly_coin, "global_position", to_pos, FLY_DURATION)
	tween.tween_property(fly_coin, "scale", Vector2.ZERO, FLY_DURATION)
	tween.tween_callback(func() -> void:
		fly_coin.queue_free()
		if add_to_bar:
			_add_coin_to_bar()
	)


func _add_coin_to_bar() -> void:
	var coin = coin_scene.instantiate()
	var stack_index := coin_bar.get_child_count(false)
	coin.position = Vector2(coin.size.x / 4, -15 + (coin.size.y + 15) * stack_index)
	coin_bar.add_child(coin)
	coin.scale = Vector2.ZERO
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(coin, "scale", Vector2.ONE, 0.2)


func add_coin_to_bar() -> void:
	_add_coin_to_bar()


func remove_coins_from_bar(count: int) -> void:
	var children := coin_bar.get_children(false)
	for _i in min(count, children.size()):
		var last = children.pop_back()
		coin_bar.remove_child(last)
		last.queue_free()


func clear_bar() -> void:
	if coin_bar == null:
		return
	for child in coin_bar.get_children(false):
		if not (child is TextureRect):
			coin_bar.remove_child(child)
			child.queue_free()
