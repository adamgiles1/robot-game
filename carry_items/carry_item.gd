class_name CarryItem extends RigidBody3D

var game_manager: GameManager
var is_replay := false
var replay_frames: Array[GameObjectFrameState]

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
	Signals.ROUND_ENDED.connect(handle_round_end)

func _physics_process(delta: float) -> void:
	if is_replay:
		update_replay_state(game_manager.current_round_time)
	else:
		create_replay_frame()

# to be called every frame the magnet is touching
func magnet_grab(pos: Vector3, vel: Vector3) -> void:
	global_position = pos
	linear_velocity = vel
	angular_velocity = Vector3.ZERO

func handle_round_end() -> void:
	freeze = true

func handle_collision(body: Node) -> void:
	if body is Attachment:
		print("touched body")
		print("offset is: ", body.global_position - global_position)
		body.touch(self)

func is_on_ground() -> bool:
	return false

func init_as_local(game_manager: GameManager) -> void:
	self.game_manager = game_manager

func init_as_replay(frames: Array[GameObjectFrameState], game_manager: GameManager) -> void:
	is_replay = true
	self.game_manager = game_manager
	replay_frames = frames

func create_replay_frame() -> void:
	var frame := GameObjectFrameState.new()
	frame.position = global_position
	game_manager.add_carry_item_frame(frame)

func update_replay_state(round_time: float) -> void:
	var frame_idx := replay_frames.rfind_custom(func(frame: GameObjectFrameState): return frame.timestamp < round_time)
	if frame_idx == -1:
		return
	var current_frame := replay_frames[frame_idx]
	global_position = current_frame.position
