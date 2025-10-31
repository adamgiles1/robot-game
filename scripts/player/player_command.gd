class_name PlayerCommand extends RefCounted

var left: float
var right: float
var action: bool
var action_alt: bool
var jump: bool

func has_movement() -> bool:
	return left || right
