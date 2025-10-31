class_name MainCamera extends Camera3D

var speed: float = 1.0
var target: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Vector3()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target == null:
		return
	var target_x_pos := target.global_position.x
	global_position.x = clamp(move_toward(global_position.x, target_x_pos, delta * speed), target_x_pos - 1.5, target_x_pos + 1.5)
	

func set_target(_target: Node3D) -> void:
	target = _target
