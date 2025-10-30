class_name Bucket extends Attachment

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func get_anim_body() -> AnimatableBody3D:
	return $RemoteTransform3D

func get_anim_proxy() -> Node3D:
	return $AnimationProxy

func interact() -> void:
	anim_player.play("pour")

func touch(item: CarryItem) -> void:
	print("bucket touched")
