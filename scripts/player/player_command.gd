class_name PlayerCommand extends RefCounted

var forwards: float
var backwards: float
var left: float
var right: float
var action: bool

func has_movement() -> bool:
	return forwards != 0.0 || backwards != 0.0 || left != 0.0 || right != 0.0

func has_rotation() -> bool:
	return left || right
