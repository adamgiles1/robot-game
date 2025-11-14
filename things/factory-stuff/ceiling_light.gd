extends Node3D

const colors: Array[Color] = [Color.AQUA, Color.AQUAMARINE, Color.YELLOW, Color.RED, Color.DARK_ORANGE, Color.GREEN]

var time_till_color_swap: float = 0.0
const TIME_BETWEEN_COLORS = 5.0

@onready var light: Light3D = $OmniLight3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_color_swap -= delta
	if time_till_color_swap < 0:
		create_tween().tween_property(light, "light_color", colors.pick_random(), TIME_BETWEEN_COLORS)
		time_till_color_swap = TIME_BETWEEN_COLORS
