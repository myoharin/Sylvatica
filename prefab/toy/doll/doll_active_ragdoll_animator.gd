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

@export var stablize_toque_strength: float = 100000
@export var stablize_force_strength: float = 3000

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

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    # move keyframe to the feet
    var direction = feet.position - animated_feet.position
    animated_torso.position += direction
    animated_head.position += direction
    animated_feet.position += direction

    # move torso and head to key frame
    if stablize_head:
        var angle_diff = angle_difference(head.rotation,animated_head.rotation)
        head.constant_torque = (exp(angle_diff)-1) * stablize_toque_strength
    if stablize_torso:
        var angle_diff = angle_difference(torso.rotation,animated_torso.rotation)
        torso.constant_torque = (exp(angle_diff)-1) * stablize_toque_strength
    # stablize feet rotation
    if stablize_feet:
        var angle_diff = angle_difference(feet.rotation,animated_feet.rotation)
        feet.constant_torque = (exp(angle_diff)-1) * stablize_toque_strength
