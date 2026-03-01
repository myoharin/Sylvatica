extends Camera2D

@export_range(0,1) var intensity: float = 0.6 # % per second
@export var target: Node2D

func get_distance_from_target() -> Vector2:
	return (get_screen_center_position() - target.position)

func _process(delta: float) -> void:
	if target != null:
		position = position.lerp(get_distance_from_target(), intensity * delta)

