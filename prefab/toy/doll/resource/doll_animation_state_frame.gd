class_name DollAnimationStateFrame
extends Resource

@export var head_transform: Transform2D = Transform2D(0, Vector2(0, -375))
@export var torso_transform: Transform2D = Transform2D(0, Vector2(0, -280))
@export var feet_transform: Transform2D = Transform2D(0, Vector2(0, -15))
@export var rotation_lock: bool = false

func _init(head_trans: Transform2D = head_transform, 
		torso_trans: Transform2D = torso_transform, 
		feet_trans: Transform2D = feet_transform, 
		is_rotation_lock: bool = false) -> void:
	head_transform = head_trans
	torso_transform = torso_trans
	feet_transform = feet_trans
	rotation_lock = is_rotation_lock