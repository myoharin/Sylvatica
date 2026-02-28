extends Node2D
# node 2D is used here so the character can be used in scene
# base node 2D should NEVER be used

@export_group("Reference Node")
@export var head: CharacterBody2D
@export var torso: CharacterBody2D
@export var feet: CharacterBody2D

@export var joint_neck_head: PinJoint2D
@export var joint_neck_torso: PinJoint2D
@export var joint_leg_torso: PinJoint2D
@export var joint_leg_feet: PinJoint2D

@export_group("Gravity Parameters")
@export_range(-1000, 10000) var gravity: float = 1000 # accerlation downwards
@export var gravity_direction: Vector2 = Vector2.DOWN

@export_group("Movement Parameters")
@export var movement_roll_count = 3
@export var movement_turning_time = 0.5 # seconds
@export var movement_dodging_time = 0.5 # seconds
@export var movement_hard_landing_time = 0.5 # seconds
@export var movement_stationary_threshold = 10 # pixel/second


# internal variables


# Facing Direction: can be modifed manually (and can be funny)
enum FacingDirection {LEFT, NEUTRAL, RIGHT}
var facing_direction: FacingDirection = FacingDirection.NEUTRAL

# Geometry States: should only be modified via change_geometry_state()
enum GeometryState {
    UPRIGHT,
    CROUCH,
    SIT,
    KNEEL,
    CRAWL,
    FLIP,
    ROLL,
    RAGDOLL
}

var geometry_state = GeometryState.UPRIGHT
func change_geometry_state(new_state: GeometryState) -> bool: # NOTDONE

    return false


# Movement States: should never be set directly, only via functions

# - basic movement states
func get_is_moving() -> bool:
    var total_velocity = head.velocity + torso.velocity + feet.velocity
    return total_velocity < movement_stationary_threshold
func get_is_walking() -> bool: # NOTDONE
    return false
func get_is_clinging() -> bool: # NOTDONE
    return torso.get_on

# - togglable timed movement states
var is_turning: bool = false
var is_dodging: bool = false
var is_hard_landed: bool = false

func trigger_turn(duration: float = movement_turning_time):
    is_turning = true
    await get_tree().create_timer(duration).timeout
    is_turning = false
func trigger_dodge(duration: float = movement_dodging_time):
    is_dodging = true
    await get_tree().create_timer(duration).timeout
    is_dodging = false
func trigger_hard_land(duration: float = movement_hard_landing_time):
    is_hard_landed = true
    await get_tree().create_timer(duration).timeout
    is_hard_landed = false

# - Others
func get_is_flipping() -> bool:
    return geometry_state == GeometryState.FLIP
func get_is_rolling() -> bool:
    return geometry_state == GeometryState.ROLL

# velocity functions

func apply_velocity_change(v: Vector2):
    head.velocity += v
    torso.velocity += v
    feet.velocity += v

func get_velocities() -> Array:
    return [
        head.velocity,
        torso.velocity,
        feet.velocity
    ]

# physics process

func _physics_process(delta: float) -> void: # grand controller

    # apply gravity to body velocity
    apply_gravity_to_body(delta, head)
    apply_gravity_to_body(delta, torso)
    apply_gravity_to_body(delta, feet)

    # amove and slide body
    head.move_and_slide()
    torso.move_and_slide()
    feet.move_and_slide()

func apply_gravity_to_body(delta: float, c: CharacterBody2D):
    var original_velocity = c.velocity
    c.velocity += gravity * delta * gravity_direction
    c.velocity = (original_velocity + c.velocity) / 2
    
