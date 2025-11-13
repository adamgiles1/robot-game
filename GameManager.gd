class_name GameManager extends Node3D

enum GameMode {WAITING, PLAYING, REPLAY, ROUND_OVER}

var robot_scn: PackedScene = preload("res://player/robot.tscn")
var carry_item: PackedScene = preload("res://carry_items/CarryItem.tscn")
var magnet_attachment: PackedScene = preload("res://player/attachments/Magnet.tscn")
var bucket_attachment: PackedScene = preload("res://player/attachments/Bucket.tscn")
var launcher_attachment: PackedScene = preload("res://player/attachments/Launcher.tscn")
var attachments: Array[PackedScene] = [bucket_attachment, launcher_attachment, magnet_attachment]
var attachment_idx: int = 0

@onready var camera: MainCamera

var player: Robot
var current_carry_item: CarryItem
var current_round: RoundInfo
var current_mode := GameMode.WAITING
var current_round_time: float = 0.0
var all_rounds: Array[RoundInfo] = []

var replay_rounds: Array[RoundInfo]
var replay_active_scene_idx: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_round(default_first_round_game_info())
	update_att_type_label(attachments[attachment_idx].resource_path.get_file())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		start_round(default_first_round_game_info())
	if Input.is_action_just_pressed("ui_down"):
		start_round(current_round)
	if Input.is_action_just_pressed("ui_right"):
		start_round(create_later_round_game_info(current_round, current_round.round + 1, current_round_time))
	if Input.is_action_just_pressed("ui_up"):
		start_replay(all_rounds)
	
	if current_mode == GameMode.PLAYING || current_mode == GameMode.REPLAY:
		current_round_time += delta
	Debug.log("roundTime", current_round_time)
	print("current carry item: ", current_carry_item)
	
	var idx_change = 0
	if Input.is_action_just_pressed("ui_text_toggle_insert_mode"): idx_change = 1
	if Input.is_action_just_pressed("ui_text_delete"): idx_change = -1
	attachment_idx = wrapi(attachment_idx + idx_change, 0, attachments.size())
	update_att_type_label(attachments[attachment_idx].resource_path.get_file())

func _physics_process(delta: float) -> void:
	if current_mode == GameMode.PLAYING && current_carry_item && current_round:
		if current_carry_item.global_position.x > current_round.round_end_distance:
			round_finished(true)
		elif current_carry_item.is_on_ground():
			round_finished(false)
	
	if current_mode == GameMode.REPLAY:
		if (replay_active_scene_idx < len(replay_rounds) - 1 &&
			current_round_time > replay_rounds[replay_active_scene_idx + 1].round_start_time):
			
			print("really is null: ", current_carry_item)
			load_next_replay_round()
		

func start_round(round_info: RoundInfo) -> void:
	print("starting round: ", round_info.round)
	clean_up_old_game()
	await get_tree().process_frame
	player = robot_scn.instantiate()
	player.rotate_y(PI/2)
	add_child(player)
	player.init_as_player(round_info.player_spawn_point, self)
	player.set_attachment(attachments[attachment_idx])
	
	camera = preload("res://player/main_camera.tscn").instantiate()
	add_child(camera)
	camera.global_position = Vector3(0, 5, 15)
	camera.set_target(player)
	
	current_round = round_info
	current_mode = GameMode.PLAYING
	
	# wait to spawn item
	await get_tree().create_timer(.25).timeout
	var item := spawn_carry_item(round_info.ball_spawn_point, round_info.ball_starting_velocity)
	item.init_as_local(self)
	#camera.set_target(item)

func start_replay(round_infos: Array[RoundInfo]) -> void:
	print("starting replay of %s rounds" % len(round_infos))
	clean_up_old_game()
	await get_tree().process_frame
	current_round_time = 0
	replay_rounds = round_infos
	await get_tree().process_frame
	
	for round_info in round_infos:
		player = robot_scn.instantiate()
		player.rotate_y(PI/2)
		add_child(player)
		player.init_as_replay(round_info.player_spawn_point, round_info.robot_positions, self)
		player.set_attachment(attachments[attachment_idx])
	
	camera = preload("res://player/main_camera.tscn").instantiate()
	add_child(camera)
	camera.global_position = Vector3(0, 5, 15)
	camera.set_target(player)
	
	current_mode = GameMode.REPLAY
	
	# wait to spawn item TODO this should happen based off the replay, not hardcoded
	await get_tree().create_timer(.25).timeout
	var item := spawn_carry_item(round_infos[0].ball_spawn_point, round_infos[0].ball_starting_velocity)
	item.init_as_replay(round_infos[0].ball_positions, self)
	camera.set_target(item)

func round_finished(success: bool) -> void:
	print("round finished with ", "success" if success else "failure")
	AudioService.play_sound("round-end-temp")
	
	if success && current_mode == GameMode.PLAYING:
		current_round.final_ball_point = current_carry_item.global_position
		current_round.final_ball_velocity = current_carry_item.linear_velocity
	
	current_mode = GameMode.ROUND_OVER
	all_rounds.append(current_round)
	Signals.ROUND_ENDED.emit()

func load_next_replay_round() -> void:
	print("swapping replay to next round")
	replay_active_scene_idx += 1
	var active_round = replay_rounds[replay_active_scene_idx]
	current_carry_item.init_as_replay(active_round.ball_positions, self)

func clean_up_old_game():
	replay_active_scene_idx = 0
	for node in get_tree().get_nodes_in_group("GameCleanup"):
		node.queue_free()

func spawn_carry_item(spawn_point: Vector3, starting_velocity: Vector3) -> CarryItem:
	var item: CarryItem = carry_item.instantiate()
	add_child(item)
	item.global_position = spawn_point
	item.linear_velocity = starting_velocity
	current_carry_item = item
	print("is null: ", current_carry_item == null)
	return item

func update_att_type_label(attachment_name: String) -> void:
	$AttachmentType.text = "next attachment: " + attachment_name

func add_robot_frame(frame: GameObjectFrameState) -> void:
	frame.timestamp = current_round_time
	current_round.add_robot_position(frame)

func add_carry_item_frame(frame: GameObjectFrameState) -> void:
	frame.timestamp = current_round_time
	current_round.add_ball_position(frame)

func default_first_round_game_info() -> RoundInfo:
	var info := RoundInfo.new()
	info.player_spawn_point = Vector3(0, 1, 0)
	info.ball_spawn_point = Vector3(-5, 4, 0)
	info.ball_starting_velocity = Vector3(5, 5, 0)
	info.round_end_distance = 30
	return info

func create_later_round_game_info(previous_round: RoundInfo, round_num: int, start_time: float) -> RoundInfo:
	var info := RoundInfo.new()
	info.previous_round = previous_round
	info.round = round_num
	info.round_start_time = start_time
	
	var round_distance_offset: int = 30 * round_num
	info.player_spawn_point = Vector3(round_distance_offset + 2, 1, 0)
	
	if previous_round.final_ball_point:
		info.ball_spawn_point = previous_round.final_ball_point
		info.ball_starting_velocity = previous_round.final_ball_velocity
	else:
		info.ball_spawn_point = Vector3(-5, 4, 0) + info.player_spawn_point
		info.ball_starting_velocity = Vector3(5, 5, 0)
	
	info.round_end_distance = round_distance_offset + 30
	return info
