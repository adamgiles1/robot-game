extends Control

var label: Label

var values: Dictionary[String, String] = {}
var values_touched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var debug_info = preload("res://debugging/DebugInfo.tscn").instantiate()
	add_child(debug_info)
	label = debug_info.get_node("Label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if values_touched:
		var text = ""
		for key: String in values.keys():
			text += str(key, ": ", values[key], "\n")
		
		label.text = text

func log(name: String, value: Variant) -> void:
	values[name] = str(value)
	values_touched = true
