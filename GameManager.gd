class_name GameManager extends Node3D

var robot_scn: PackedScene = preload("res://player/robot.tscn")
var carry_item: PackedScene = preload("res://carry_items/CarryItem.tscn")
var magnet_attachment: PackedScene = preload("res://player/attachments/Magnet.tscn")

var player: Robot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_game() -> void:
	player = robot_scn.instantiate()
	add_child(player)
	player.init_as_player(Vector3(0, 1, 0))
	player.set_attachment(magnet_attachment)
	
	# wait to spawn item
	await get_tree().create_timer(3).timeout
	var item: CarryItem = carry_item.instantiate()
	add_child(item)
	item.global_position = Vector3(0, 4, 0)
	
