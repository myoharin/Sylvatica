class_name DollGeometryStateFrame
extends Resource

@export var head_transform: Transform2D
@export var torso_transform: Transform2D
@export var feet_transform: Transform2D
@export var rotation_lock: bool

func _init(head_trans: Transform2D, 
		torso_trans: Transform2D, 
		feet_trans: Transform2D, 
		is_rotation_lock: bool) -> void:
	head_transform = head_trans
	torso_transform = torso_trans
	feet_transform = feet_trans
	rotation_lock = is_rotation_lock