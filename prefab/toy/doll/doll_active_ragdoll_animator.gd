class_name DollActiveRagdollAnimator
extends Node

# - Jump Types
enum JumpState {
    NONE, # when no jumps are initiated
    FLIP, # spin jump
    HOP, # standing jump with no momentum, valuing maintaing stability
    POUNCE, # crawl jump
    PRANCE, # standing jump ADDING momentum, valuing speed
}
# - Facing Direction: can be modifed manually (and can be funny)
enum FacingDirection {LEFT, NEUTRAL, RIGHT}

# - Geometry States:
enum AnimationState {
    UPRIGHT,
    CROUCH,
    SIT,
    KNEEL,
    CRAWL,
    FLIP,
    ROLL,
    RAGDOLL
}

@export_group("Reference Nodes")
@export var doll: Doll

@export var head: RigidBody2D
@export var torso: RigidBody2D
@export var hip: RigidBody2D
@export var ankle: RigidBody2D
@export var feet: RigidBody2D

@export var ankle_joint: Joint2D
@export var hip_joint: Joint2D
@export var leg: GrooveJoint2D

@export var animated_head: StaticBody2D
@export var animated_torso: StaticBody2D
@export var animated_feet: StaticBody2D

@export var feet_stablization_toque_strength: float = 1000

@export var animated_body_follow_strength: float = 5
@export var keyframe_reaction_threshold: float = 0 # pixel
@export var ragdoll_angular_sleep_threshold: float = 1 # radians/s
@export var ragdoll_rotation_sleep_threshold: float = 0.1 # radians/s
@export var animated_body_force_stablization_threshold: float = 10

# internal variables

var facing_direction: FacingDirection = FacingDirection.NEUTRAL
var jump_state: JumpState = JumpState.NONE
var geometry_state = AnimationState.UPRIGHT

# Rigid body states
# - Stablize main physics body, including rotation and location to animated body
# - stabllization is done using tweens in _physics_process()
var stablize_head: bool = true
var stablize_torso: bool = true
var stablize_feet: bool = true

var animated_feet_last_pos = Vector2(0,0)

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    pass
    # move keyframe to the feet
    var direction = (feet.position - animated_feet.position)
    if direction.length_squared() > keyframe_reaction_threshold:
        var move_force = direction * animated_body_follow_strength * delta
        animated_torso.position += move_force
        animated_head.position += move_force 
        animated_feet.position += move_force

    print(feet.sleeping, feet.angular_velocity)
    
    # stablize ragdoll
    # if stablize_feet:
    #     var animated_feet_velocity = animated_feet_last_pos - animated_feet.position
    #     animated_feet_last_pos = animated_feet.position
    #     if animated_feet_velocity.length_squared() < animated_body_force_stablization_threshold:
    #         feet.sleeping = true
    #         feet.rotation = 0
    #         feet.linear_velocity = Vector2(0,0)

    #     if feet.angular_velocity < ragdoll_angular_sleep_threshold:
    #         if feet.rotation < ragdoll_rotation_sleep_threshold:
    #             feet.sleeping = true
    #             feet.rotation = 0
    #             feet.linear_velocity = Vector2(0,0)
    
# helper functions
func calculate_stablization_toque(angle_diff: float) -> float:
    return (exp(abs(angle_diff))-1) * feet_stablization_toque_strength