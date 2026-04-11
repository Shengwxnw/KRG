extends Object

class_name State

var name : String
var next : State
var operator : Player

func _new(name, next, operator):
	self.name = name
	self.next = next
	self.operator = operator
