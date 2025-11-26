class_name Fan extends Node3D

@onready var area: Area3D = $Area3D
@onready var fan_rotar: Node3D = $fan/Cylinder

var force: Vector3 = Vector3(0, 20, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if area.has_overlapping_bodies():
		for item: CarryItem in area.get_overlapping_bodies():
			item.set_wind_force(force)
	
	fan_rotar.rotate_y(delta * -8)
