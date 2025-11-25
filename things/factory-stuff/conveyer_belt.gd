extends Node3D

@onready var area: Area3D = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if area.has_overlapping_bodies():
		for item: CarryItem in area.get_overlapping_bodies():
			item.set_touching_conveyer_belt()
		
