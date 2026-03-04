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

@export var head_drag_joint: PinJoint2D
@export var torso_drag_joint: PinJoint2D
@export var feet_drag_joint: PinJoint2D

@export_group("Stablization Parameters")
@export var feet_stablization_toque_strength: float = 1000

@export var animated_body_follow_strength: float = 5
@export var keyframe_reaction_threshold: float = 0 # pixel
@export var ragdoll_angular_sleep_threshold: float = 1 # radians/s
@export var ragdoll_rotation_sleep_threshold: float = 0.1 # radians/s
@export var animated_body_force_stablization_threshold: float = 10
@export var animation_frame_interpolation_weight: float = 0.3

@export_group("Geometry State Frames")
@export var upright_frame: DollAnimationStateFrame
@export var crouch_frame: DollAnimationStateFrame
@export var sit_frame: DollAnimationStateFrame
@export var kneel_frame: DollAnimationStateFrame
@export var crawl_frame: DollAnimationStateFrame
@export var flip_frame: DollAnimationStateFrame
@export var roll_frame: DollAnimationStateFrame

# Set ups

@onready
var animation_state_to_frame = { # mapping
    AnimationState.UPRIGHT: upright_frame,
    AnimationState.CROUCH: crouch_frame,
    AnimationState.SIT: sit_frame,
    AnimationState.KNEEL: kneel_frame,
    AnimationState.CRAWL: crawl_frame,
    AnimationState.FLIP: flip_frame,
    AnimationState.ROLL: roll_frame,
    AnimationState.RAGDOLL: null, # no animation frame, pure ragdoll
}

# variables

var facing_direction: FacingDirection = FacingDirection.NEUTRAL
var jump_state: JumpState = JumpState.NONE
var animation_state = AnimationState.UPRIGHT # deafult
var drag_points_connected: bool = true

# functions

func change_animation_state(new_state: AnimationState) -> void:
    if new_state == animation_state:
        return # no change
    animation_state = new_state
    if animation_state == AnimationState.RAGDOLL:
        release_drag_joints()
    else:
        connect_drag_joints()

func release_drag_joints() -> void:
    feet_drag_joint.node_b = ""
    torso_drag_joint.node_b = ""
    head_drag_joint.node_b = ""

func connect_drag_joints() -> void:
    # move ragdoll parts to the animated body position
    animated_head.global_transform = head.global_transform
    animated_torso.global_transform = torso.global_transform
    animated_feet.global_transform = feet.global_transform

    # connect joints
    feet_drag_joint.node_b = feet.get_path()
    torso_drag_joint.node_b = torso.get_path()
    head_drag_joint.node_b = head.get_path()


# Processes

func _init() -> void:
    pass


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("test_1"): # cycle through animation states for testing
        animation_state = (animation_state + 1) % 7 as AnimationState
        print(animation_state)

func _physics_process(delta: float) -> void:
    # joint conecction and release for testing
    if Input.is_action_just_pressed("test_2"): # toggle drag joints for testing
        if drag_points_connected:
            release_drag_joints()
            print("Drag joints released, pure ragdoll mode")
        else:
            connect_drag_joints()
            print("Drag joints connected, active ragdoll mode")
        drag_points_connected = !drag_points_connected

    # lerp animated body to the ragdolls position
    for parts in [
        [head,animated_head], 
        [torso,animated_torso], 
        [feet,animated_feet]]:

        var part = parts[0]
        var animated_part = parts[1]
        var direction = (part.position - animated_part.position)
        if direction.length_squared() > keyframe_reaction_threshold:
            var move_force = direction * animated_body_follow_strength * delta
            animated_part.position += move_force

    

    
    # move animation keyframe to the intended frame of AnimationState (relative to feet)
    var frame = animation_state_to_frame[animation_state]
    var ragdoll_centre = (
        feet.position + torso.position + head.position) / 3
    var anchor_point = Vector2(ragdoll_centre.x, feet.position.y-frame.feet_transform.origin.y)
    
    if animation_state != null:
        # local transform to their parent: `animated_body_root`
        animated_head.transform = animated_head.transform.interpolate_with(
            frame.head_transform.translated(anchor_point),
            animation_frame_interpolation_weight)
        animated_torso.transform = animated_torso.transform.interpolate_with(
            frame.torso_transform.translated(anchor_point),
            animation_frame_interpolation_weight)
        animated_feet.transform = animated_feet.transform.interpolate_with(
            frame.feet_transform.translated(anchor_point),
            animation_frame_interpolation_weight)
    else: # do nothing, it is ragdoll
        pass #print("Ragdoll state, no animation frame")

func calculate_stablization_toque(angle_diff: float) -> float:
    return (exp(abs(angle_diff))-1) * feet_stablization_toque_strength
