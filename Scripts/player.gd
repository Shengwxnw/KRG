extends Node

@export var side: bool
var deck
func _ready() -> void:
	deck = []
	setup_layout()

func setup_layout() -> void:
	print(side)
	if side:
		for child in get_children():
			if child is Control:
				child.position.y = 1200 - child.position.y - child.size.y
			else:
				for nieto in child.get_children():
					if nieto is Control:
						nieto.position.y = 1200 - nieto.position.y - nieto.size.y * nieto.scale.x
