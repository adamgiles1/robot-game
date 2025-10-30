class_name Robot extends CharacterBody3D


var max_velocity: float = 5.0
var current_speed: float = 0.0
var move_speed: float = 5.0
var damping_force: float = 10.0

var attachment: Attachment

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var command := get_command()
	
	# handle action
	if command.action:
		attempt_action()
	
	# handle movement
	if command.left:
		current_speed = clampf(current_speed + delta * move_speed, -max_velocity, max_velocity)
	elif command.right:
		current_speed = clampf(current_speed - delta * move_speed, -max_velocity, max_velocity)
	else:
		current_speed = move_toward(current_speed, 0, delta * damping_force)
	
	var adj_vel := Vector3(-current_speed, 0, 0)
	velocity = adj_vel

	move_and_slide()
	
	animate_treads(delta)
	
	update_attachment()

func attempt_action() -> void:
	if attachment:
		attachment.interact()

func animate_treads(delta: float) -> void:
	$Treads/Left.rotate_x(-delta * current_speed)
	$Treads/Right.rotate_x(-delta * current_speed)

func get_command() -> PlayerCommand:
	var command := PlayerCommand.new()
	command.action = Input.is_action_just_pressed("action")
	command.right = Input.get_action_strength("right")
	command.left = Input.get_action_strength("left")
	return command

func init_as_player(pos: Vector3) -> void:
	global_position = pos

func update_attachment() -> void:
	if attachment:
		attachment.move($AttachmentSpot.global_position)

func set_attachment(attachment_scn: PackedScene) -> void:
	attachment = attachment_scn.instantiate()
	add_child(attachment)
