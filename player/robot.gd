class_name Robot extends CharacterBody3D

var game_manager: GameManager

var max_velocity: float = 5.0
var current_speed: float = 0.0
var current_vertical_speed: float = 0.0
var move_speed: float = 5.0
var damping_force: float = 10.0

var attachment: Attachment

var is_frozen := false
var is_replay := false
var replay_frames: Array[GameObjectFrameState]

func _ready() -> void:
	Signals.ROUND_ENDED.connect(handle_round_end)

func _physics_process(delta: float) -> void:
	if is_frozen:
		return
	if is_replay:
		update_attachment()
		update_replay_state(game_manager.current_round_time)
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var command := get_command()
	
	# handle action
	if command.action:
		attempt_action()
	if command.action_alt:
		attempt_alt_action()
	
	# handle movement
	if command.left:
		current_speed = clampf(current_speed + delta * move_speed, -max_velocity, max_velocity)
	elif command.right:
		current_speed = clampf(current_speed - delta * move_speed, -max_velocity, max_velocity)
	else:
		current_speed = move_toward(current_speed, 0, delta * damping_force)
	
	# handle vertical movement
	if is_on_floor():
		current_vertical_speed = 0.0
		if command.jump:
			current_vertical_speed = 5.0
	else:
		# apply gravity
		current_vertical_speed += get_gravity().y * delta
	
	var adj_vel := Vector3(-current_speed, current_vertical_speed, 0)
	velocity = adj_vel

	move_and_slide()
	
	animate_treads(delta)
	
	update_attachment()
	
	create_replay_frame()
	
	# debugging
	Debug.log("robotPos", global_position)

func attempt_action() -> void:
	if attachment:
		attachment.interact()

func attempt_alt_action() -> void:
	if attachment:
		attachment.interact_alt()

func animate_treads(delta: float) -> void:
	$Treads/Left.rotate_x(-delta * current_speed)
	$Treads/Right.rotate_x(-delta * current_speed)

func get_command() -> PlayerCommand:
	var command := PlayerCommand.new()
	command.action = Input.is_action_just_pressed("action")
	command.action_alt = Input.is_action_just_pressed("action_alt")
	command.right = Input.get_action_strength("right")
	command.left = Input.get_action_strength("left")
	command.jump = Input.is_action_just_pressed("jump")
	return command

func init_as_player(pos: Vector3, game_manager: GameManager) -> void:
	global_position = pos
	self.game_manager = game_manager

func init_as_replay(pos: Vector3, frames: Array[GameObjectFrameState], game_manager: GameManager) -> void:
	is_replay = true
	global_position = pos
	self.game_manager = game_manager
	replay_frames = frames

func update_attachment() -> void:
	if attachment:
		attachment.move($AttachmentSpot.global_position)

func set_attachment(attachment_scn: PackedScene) -> void:
	attachment = attachment_scn.instantiate()
	add_child(attachment)

func handle_round_end() -> void:
	is_frozen = true

func create_replay_frame() -> void:
	var frame := GameObjectFrameState.new()
	frame.position = global_position
	game_manager.add_robot_frame(frame)

func update_replay_state(round_time: float) -> void:
	var frame_idx := replay_frames.rfind_custom(func(frame: GameObjectFrameState): return frame.timestamp < round_time)
	if frame_idx == -1:
		return
	var current_frame := replay_frames[frame_idx]
	global_position = current_frame.position
