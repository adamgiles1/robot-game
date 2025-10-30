class_name GameManager extends Node3D

var robot_scn: PackedScene = preload("res://player/robot.tscn")
var carry_item: PackedScene = preload("res://carry_items/CarryItem.tscn")
var magnet_attachment: PackedScene = preload("res://player/attachments/Magnet.tscn")
var bucket_attachment: PackedScene = preload("res://player/attachments/Bucket.tscn")

@onready var camera: MainCamera

var player: Robot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_game() -> void:
	player = robot_scn.instantiate()
	player.rotate_y(PI/2)
	add_child(player)
	player.init_as_player(Vector3(0, 1, 0))
	player.set_attachment(bucket_attachment)
	
	camera = preload("res://player/main_camera.tscn").instantiate()
	add_child(camera)
	camera.global_position = Vector3(0, 10, 10)
	camera.set_target(player)
	
	# wait to spawn item
	await get_tree().create_timer(3).timeout
	var item: CarryItem = carry_item.instantiate()
	add_child(item)
	item.global_position = Vector3(0, 4, 0)
	
