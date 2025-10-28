class_name Robot extends CharacterBody3D


var max_velocity: float = 5.0
var current_speed: float = 0.0
var move_speed: float = 5.0
var turn_speed: float = .3
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
	
	# handle rotation
	if command.left:
		rotate_y(delta * turn_speed * (-1 if current_speed < 0 else 1))
	elif command.right:
		rotate_y(-delta * turn_speed * (-1 if current_speed < 0 else 1))
	
	# handle movement
	if command.forwards:
		current_speed = clampf(current_speed + delta * move_speed, -max_velocity, max_velocity)
	elif command.backwards:
		current_speed = clampf(current_speed - delta * move_speed, -max_velocity, max_velocity)
	else:
		current_speed = move_toward(current_speed, 0, delta * damping_force)
	var adj_vel := Vector3(0, 0, -current_speed).rotated(Vector3.UP, rotation.y)
	adj_vel = adj_vel
	velocity = adj_vel

	move_and_slide()
	
	animate_treads(delta, command)
	
	update_attachment()

func attempt_action() -> void:
	if attachment:
		attachment.interact()

func animate_treads(delta: float, command: PlayerCommand) -> void:
	var l_forwards := true
	var r_forwards := true
	if command.left:
		l_forwards = false
	elif command.right:
		r_forwards = false
	var rotate_speed = current_speed
	if command.has_rotation():
		rotate_speed = 3.0
	$Treads/Left.rotate_x(-delta * rotate_speed * (1 if l_forwards else -1))
	$Treads/Right.rotate_x(-delta * rotate_speed * (1 if r_forwards else -1))

func get_command() -> PlayerCommand:
	var command := PlayerCommand.new()
	command.action = Input.is_action_just_pressed("action")
	command.forwards = Input.get_action_strength("forward")
	command.backwards = Input.get_action_strength("backward")
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
