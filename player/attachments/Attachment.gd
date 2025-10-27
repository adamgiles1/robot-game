@abstract class_name Attachment extends AnimatableBody3D

var robot: Robot

@abstract
func interact() -> void

@abstract
func touch(item: CarryItem) -> void

func move(pos: Vector3) -> void:
	global_position = pos
