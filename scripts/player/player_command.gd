class_name PlayerCommand extends RefCounted

var left: float
var right: float
var action: bool

func has_movement() -> bool:
	return left || right
