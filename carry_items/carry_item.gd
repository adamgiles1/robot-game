class_name CarryItem extends RigidBody3D

func _ready() -> void:
	body_entered.connect(handle_collision)
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, true)
	add_to_group("GameCleanup")
	#axis_lock_angular_z = true
	axis_lock_linear_z = true
	max_contacts_reported = 10
	contact_monitor = true

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
