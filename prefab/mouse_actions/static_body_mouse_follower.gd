extends StaticBody2D

@export_range(0.1,10) var tenacity: float = 0.8

var last_position: Vector2 = position

func _physics_process(delta: float) -> void:
    constant_linear_velocity = (position - last_position) / delta * 0.2
    last_position = position
    position = position.lerp(get_global_mouse_position(), tenacity)

