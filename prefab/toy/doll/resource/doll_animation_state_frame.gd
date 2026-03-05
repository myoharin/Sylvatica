class_name DollAnimationStateFrame
extends Resource

@export var head_transform: Transform2D = Transform2D(0, Vector2(0, -375))
@export var torso_transform: Transform2D = Transform2D(0, Vector2(0, -280))
@export var feet_transform: Transform2D = Transform2D(0, Vector2(0, -15))
@export var rotation_lock: bool = false

func _init() -> void:
	pass

func clone() -> DollAnimationStateFrame:
	var new_frame = DollAnimationStateFrame.new()
	new_frame.head_transform = Transform2D(head_transform)
	new_frame.torso_transform = Transform2D(torso_transform)
	new_frame.feet_transform = Transform2D(feet_transform)
	new_frame.rotation_lock = rotation_lock
	return new_frame