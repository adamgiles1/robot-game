@abstract class_name Attachment extends Node3D

var robot: Robot
var body: Node3D

var offset_pos: Vector3 = Vector3.ZERO
var offset_rot: Vector3 = Vector3.ZERO
var anim_proxy: Node3D

func _ready() -> void:
	body = get_anim_body()
	anim_proxy = get_anim_proxy()

func _physics_process(delta: float) -> void:
	if anim_proxy:
		offset_pos = anim_proxy.position
		offset_rot = anim_proxy.rotation

@abstract
func interact() -> void

@abstract
func touch(item: CarryItem) -> void

@abstract
func get_anim_body() -> Node3D

func get_anim_proxy() -> Node3D:
	return null

func move(pos: Vector3) -> void:
	body.global_position = pos + offset_pos
	body.rotation = offset_rot
