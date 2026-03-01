extends RayCast2D

@export_range(0.1,1000) var tenacity: float = 300
var grabbed: CollisionObject2D = null
var previous_tick_try_select = false
# clipping is guanteed because teleportation is used.

func _process(delta: float) -> void:
    position = get_global_mouse_position()
    if Input.is_action_just_pressed("mouse_grabber_select"):
        previous_tick_try_select = true
        position = get_global_mouse_position()
        print(get_collider())

    if previous_tick_try_select:
        previous_tick_try_select = false
        if grabbed == null: # is collide isnt updated yet, so delayed 1 tick
            var obj = get_collider()
            if obj is CollisionObject2D:
                grabbed = obj

                print(obj.position)
                print("Mouse grabber selected new object %s." % obj)
            else:
                print("Mouse grabber tried select failed.")
        else:
            print("Mouse grabber release %s." % grabbed)
            if grabbed is RigidBody2D:
                grabbed.sleeping = false
            grabbed = null

    if grabbed != null:
        var direction = (get_global_mouse_position() - grabbed.position - position)
        if grabbed is StaticBody2D:
            grabbed.constant_linear_velocity = direction
        if grabbed is RigidBody2D:
            grabbed.apply_central_force(direction * tenacity * grabbed.mass)
