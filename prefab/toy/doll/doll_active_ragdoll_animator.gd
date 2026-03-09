class_name DollActiveRagdollAnimator
extends Node

var unturnable_states = [
        doll.AnimationState.CRAWL,
        doll.AnimationState.KNEEL,
        doll.AnimationState.SIT,
    ]
var unjumpable_states = [
    doll.AnimationState.CRAWL,
    doll.AnimationState.RAGDOLL,
    doll.AnimationState.SIT
]

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
@export var character_shape: CollisionShape2D

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
    doll.AnimationState.UPRIGHT: upright_frame,
    doll.AnimationState.CROUCH: crouch_frame,
    doll.AnimationState.SIT: sit_frame,
    doll.AnimationState.KNEEL: kneel_frame,
    doll.AnimationState.CRAWL: crawl_frame,
    doll.AnimationState.FLIP: flip_frame,
    doll.AnimationState.ROLL: roll_frame,
    doll.AnimationState.RAGDOLL: null, # no animation frame, pure ragdoll
}

# variables

var facing_direction: int = doll.FacingDirection.NEUTRAL
var last_facing_direction: int = doll.FacingDirection.RIGHT
var animation_state = doll.AnimationState.UPRIGHT as int # deafult
var drag_points_connected: bool = true

var awaiting_animation_state: int = -1 # doll.AnimationState

# functions

func call_change_animation_state(new_state: int) -> void:
    awaiting_animation_state = new_state
# done within physics tick
func _change_animation_state(new_state: int) -> void:
    animation_state = new_state # no question asked
    if animation_state == doll.AnimationState.RAGDOLL:
        _release_drag_joints()
    else:
        _connect_drag_joints()
    if unturnable_states.has(animation_state):
        facing_direction = last_facing_direction
# done within physics tick
func _release_drag_joints() -> void:
    feet_drag_joint.node_b = ""
    torso_drag_joint.node_b = ""
    head_drag_joint.node_b = ""
# done within physics tick
func _connect_drag_joints() -> void:
    # move ragdoll parts to the animated body position
    animated_head.transform = head.transform
    animated_torso.transform = torso.transform
    animated_feet.transform = feet.transform

    print(animated_head.transform)
    print(head.transform)
    print(animated_torso.transform)
    print(torso.transform)
    print(animated_feet.transform)
    print(feet.transform)


    # connect joints
    feet_drag_joint.node_b = feet.get_path()
    torso_drag_joint.node_b = torso.get_path()
    head_drag_joint.node_b = head.get_path()

# connection functions

func report_ragdoll_component_contact( # NOT DONE
        type: int, # doll.AnimationState
        _contact_impulse: Vector2) -> void:
    
    var animated_component: StaticBody2D = null
    var component: RigidBody2D = null
    match type:
        doll.RagdollComponentType.HEAD:
            animated_component = animated_head
            component = head
            # print("Head contact with impulse: ", contact_impulse)
        doll.RagdollComponentType.TORSO:
            animated_component = animated_torso
            component = torso
            # print("Torso contact with impulse: ", contact_impulse)
        doll.RagdollComponentType.FEET:
            animated_component = animated_feet
            component = feet
            # print("Feet contact with impulse: ", contact_impulse)
    
    # animated_component.position += contact_impulse * 0.5 / component.mass

# Processes

func _init() -> void:
    connect_drag_joints()
    pass


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("test_1"): # cycle through animation states for testing
        animation_state = (animation_state + 1) % len(doll.AnimationState)
        print(animation_state)

func _physics_process(_delta: float) -> void:
    # update facing direction
    last_facing_direction = (
        last_facing_direction * int(bool(facing_direction == 0))) + (
            facing_direction * int(bool(facing_direction != 0)))

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
    var frame = (animation_state_to_frame[animation_state] as DollAnimationStateFrame)
    if frame != null:
        frame = frame.clone()
         # - invert x for direction purposes
        var facing_direction_multiplier = last_facing_direction
        
        frame.head_transform.origin.x *= facing_direction_multiplier
        frame.torso_transform.origin.x *= facing_direction_multiplier
        frame.feet_transform.origin.x *= facing_direction_multiplier

        # local transform to their parent: `animated_body_root`
        animated_head.transform = animated_head.transform.interpolate_with(
            frame.head_transform.translated(character_body.position),
            animation_frame_interpolation_weight)
        animated_torso.transform = animated_torso.transform.interpolate_with(
            frame.torso_transform.translated(character_body.position),
            animation_frame_interpolation_weight)
        animated_feet.transform = animated_feet.transform.interpolate_with(
            frame.feet_transform.translated(character_body.position),
            animation_frame_interpolation_weight)
    else: # do nothing, it is ragdoll
        # print("Ragdoll state, no animation frame")
        pass

    # - Alter character_body hitbox
    var newshape: RectangleShape2D = character_shape.shape.duplicate_deep()
    newshape.size = newshape.size.lerp(frame.hitbox_size, pow(0.5, 0.8*_delta))
    character_shape.shape = newshape
    var target_position = Vector2(0, newshape.size.y * -0.5)
    character_shape.position = character_shape.position.lerp(
        target_position, pow(0.5, 0.8*_delta))
    
