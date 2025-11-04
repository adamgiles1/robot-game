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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_round(default_first_round_game_info())
	update_att_type_label(attachments[attachment_idx].resource_path.get_file())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		start_round(default_first_round_game_info())
	if Input.is_action_just_pressed("ui_right"):
		AudioService.play_sound("round-end-temp")
	
	var idx_change = 0
	if Input.is_action_just_pressed("ui_up"): idx_change = 1
	if Input.is_action_just_pressed("ui_down"): idx_change = -1
	attachment_idx = wrapi(attachment_idx + idx_change, 0, attachments.size())
	update_att_type_label(attachments[attachment_idx].resource_path.get_file())

func _physics_process(delta: float) -> void:
	if current_mode == GameMode.PLAYING && current_carry_item && current_round:
		if current_carry_item.global_position.x > current_round.round_end_distance:
			round_finished(true)
		elif current_carry_item.is_on_ground():
			round_finished(false)

func start_round(round_info: RoundInfo) -> void:
	clean_up_old_game()
	await get_tree().process_frame
	player = robot_scn.instantiate()
	player.rotate_y(PI/2)
	add_child(player)
	player.init_as_player(round_info.player_spawn_point)
	player.set_attachment(attachments[attachment_idx])
	
	camera = preload("res://player/main_camera.tscn").instantiate()
	add_child(camera)
	camera.global_position = Vector3(0, 5, 10)
	camera.set_target(player)
	
	current_round = round_info
	current_mode = GameMode.PLAYING
	
	# wait to spawn item
	await get_tree().create_timer(.25).timeout
	spawn_carry_item(round_info.ball_spawn_point, round_info.ball_starting_velocity)

func round_finished(success: bool) -> void:
	print("round finished")
	current_mode = GameMode.ROUND_OVER
	Signals.ROUND_ENDED.emit()

func clean_up_old_game():
	for node in get_tree().get_nodes_in_group("GameCleanup"):
		node.queue_free()

func spawn_carry_item(spawn_point: Vector3, starting_velocity: Vector3) -> CarryItem:
	var item: CarryItem = carry_item.instantiate()
	add_child(item)
	item.global_position = spawn_point
	item.linear_velocity = starting_velocity
	current_carry_item = item
	return item

func update_att_type_label(attachment_name: String) -> void:
	$AttachmentType.text = "next attachment: " + attachment_name

func default_first_round_game_info() -> RoundInfo:
	var info := RoundInfo.new()
	info.player_spawn_point = Vector3(0, 1, 0)
	info.ball_spawn_point = Vector3(-5, 4, 0)
	info.ball_starting_velocity = Vector3(5, 5, 0)
	info.round_end_distance = 30
	return info

func replay_rounds(rounds: Array[RoundInfo]) -> void:
	print("replaying %s rounds" % len(rounds))
