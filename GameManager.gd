class_name GameManager extends Node3D

var robot_scn: PackedScene = preload("res://player/robot.tscn")
var carry_item: PackedScene = preload("res://carry_items/CarryItem.tscn")
var magnet_attachment: PackedScene = preload("res://player/attachments/Magnet.tscn")
var bucket_attachment: PackedScene = preload("res://player/attachments/Bucket.tscn")
var launcher_attachment: PackedScene = preload("res://player/attachments/Launcher.tscn")
var attachments: Array[PackedScene] = [bucket_attachment, launcher_attachment, magnet_attachment]
var attachment_idx: int = 0

@onready var camera: MainCamera

var player: Robot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()
	update_att_type_label(attachments[attachment_idx].resource_path.get_file())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		start_game()
	
	var idx_change = 0
	if Input.is_action_just_pressed("ui_up"): idx_change = 1
	if Input.is_action_just_pressed("ui_down"): idx_change = -1
	attachment_idx = wrapi(attachment_idx + idx_change, 0, attachments.size())
	update_att_type_label(attachments[attachment_idx].resource_path.get_file())

func start_game() -> void:
	clean_up_old_game()
	await get_tree().process_frame
	player = robot_scn.instantiate()
	player.rotate_y(PI/2)
	add_child(player)
	player.init_as_player(Vector3(0, 1, 0))
	player.set_attachment(attachments[attachment_idx])
	
	camera = preload("res://player/main_camera.tscn").instantiate()
	add_child(camera)
	camera.global_position = Vector3(0, 10, 10)
	camera.set_target(player)
	
	# wait to spawn item
	await get_tree().create_timer(.25).timeout
	var item: CarryItem = carry_item.instantiate()
	add_child(item)
	item.global_position = Vector3(0, 4, 0)

func clean_up_old_game():
	for node in get_tree().get_nodes_in_group("GameCleanup"):
		node.queue_free()

func update_att_type_label(attachment_name: String) -> void:
	$AttachmentType.text = "next attachment: " + attachment_name
