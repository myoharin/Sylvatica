extends Node

@export var targets: Array
@export_range(-1000, 10000) var gravity: float = 1000 # accerlation downwards
@export var gravity_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
    var acceleration_halved = (_delta * gravity * gravity_direction)/2
    for c in targets:
        var body = c as CharacterBody2D
        if body != null:
            body.velocity += acceleration_halved # add average velocity
            body.move_and_slide()
            

