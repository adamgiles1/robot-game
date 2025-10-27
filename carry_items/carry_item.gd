class_name CarryItem extends RigidBody3D

func _ready() -> void:
	body_entered.connect(handle_collision)

# to be called every frame the magnet is touching
func magnet_grab(pos: Vector3, vel: Vector3) -> void:
	global_position = pos
	linear_velocity = vel
	angular_velocity = Vector3.ZERO

func handle_collision(body: Node) -> void:
	if body is Attachment:
		print("touched body")
		print("offset is: ", body.global_position - global_position)
		body.touch(self)
