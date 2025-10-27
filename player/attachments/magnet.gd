class_name Magnet extends Attachment

var is_on: bool = true
var attached_items: Array[MagnetTouchInfo]

func _physics_process(delta: float) -> void:
	if is_on:
		for info: MagnetTouchInfo in attached_items:
			info.item.magnet_grab(global_position + info.offset, constant_linear_velocity)

func interact() -> void:
	is_on = !is_on
	print("magnet turning ", "on" if is_on else "off")
	if !is_on:
		attached_items.clear()

func touch(touched: CarryItem) -> void:
	if is_on && !attached_items.has(touched):
		var info := MagnetTouchInfo.new()
		info.item = touched
		info.offset = touched.global_position - self.global_position
		attached_items.append(info)
