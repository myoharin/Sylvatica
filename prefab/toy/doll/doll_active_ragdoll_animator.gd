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

enum RagdollComponentType {
    HEAD = 0,
    TORSO = 1,
    FEET = 2
}

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

@export var character_body: CharacterBody2D

@export_group("Geometry State Frames")
@export var upright_frame: DollAnimationStateFrame
@export var crouch_frame: DollAnimationStateFrame
@export var sit_frame: DollAnimationStateFrame
@export var kneel_frame: DollAnimationStateFrame
@export var crawl_frame: DollAnimationStateFrame
@export var flip_frame: DollAnimationStateFrame
@export var roll_frame: DollAnimationStateFrame

@export_group("Stablization Parameters")
@export var animation_frame_interpolation_weight: float = 0.3


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

# connection functions

func report_ragdoll_component_contact( # NOT DONE
        type: RagdollComponentType,
        contact_impulse: Vector2) -> void:
    
    var animated_component: StaticBody2D = null
    var component: RigidBody2D = null
    match type:
        RagdollComponentType.HEAD:
            animated_component = animated_head
            component = head
            print("Head contact with impulse: ", contact_impulse)
        RagdollComponentType.TORSO:
            animated_component = animated_torso
            component = torso
            print("Torso contact with impulse: ", contact_impulse)
        RagdollComponentType.FEET:
            animated_component = animated_feet
            component = feet
            print("Feet contact with impulse: ", contact_impulse)
    
    # animated_component.position += contact_impulse * 0.5 / component.mass

# Processes

func _init() -> void:
    pass


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("test_1"): # cycle through animation states for testing
        animation_state = (animation_state + 1) % 7 as AnimationState
        print(animation_state)

func _physics_process(_delta: float) -> void:
    # Test: Toggle drag joint activation
    if Input.is_action_just_pressed("test_2"): # toggle drag joints for testing
        if drag_points_connected:
            release_drag_joints()
            print("Drag joints released, pure ragdoll mode")
        else:
            connect_drag_joints()
            print("Drag joints connected, active ragdoll mode")
        drag_points_connected = !drag_points_connected

    
    # move animation keyframe to the intended frame of AnimationState (relative to feet)
    var frame = animation_state_to_frame[animation_state]
    var frame_centre = (
        frame.head_transform.origin + frame.torso_transform.origin + frame.feet_transform.origin
        ) / 3.0 
    if animation_state != null:
        # local transform to their parent: `animated_body_root`
        animated_head.transform = animated_head.transform.interpolate_with(
            frame.head_transform.translated(character_body.position),
            animation_frame_interpolation_weight)
        animated_torso.transform = animated_torso.transform.interpolate_with(
            frame.torso_transform.translated(character_body.position),
            animation_frame_interpolation_weight)
    else: # do nothing, it is ragdoll
        pass #print("Ragdoll state, no animation frame")
