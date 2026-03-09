class_name Doll
extends Node2D

# centralise enum reference
# - Jump Types
enum JumpState {
    NONE = 0, # when no jumps are initiated
    FLIP = 4, # spin jump
    HOP = 1, # standing jump with no momentum, valuing maintaing stability
    POUNCE = 3, # crawl jump
    PRANCE = 2, # standing jump ADDING momentum, valuing speed
}
enum FacingDirection {LEFT = -1, NEUTRAL = 0, RIGHT = 1}
enum RagdollComponentType {
    HEAD = 0,
    TORSO = 1,
    FEET = 2
}
enum AnimationState {
    UPRIGHT = 0,
    CROUCH = 1,
    SIT = 2,
    KNEEL = 3,
    CRAWL = 4,
    FLIP = 5,
    ROLL = 6,
    RAGDOLL = 7
}
var animation_state_names = {
    AnimationState.UPRIGHT: "Upright",
    AnimationState.CROUCH: "Crouch",
    AnimationState.SIT: "Sit",
    AnimationState.KNEEL: "Kneel",
    AnimationState.CRAWL: "Crawl",
    AnimationState.FLIP: "Flip",
    AnimationState.ROLL: "Roll",
    AnimationState.RAGDOLL: "Ragdoll"
}
var try_stand_states = {
    AnimationState.CRAWL: AnimationState.SIT,
    AnimationState.SIT: AnimationState.CROUCH,
    AnimationState.KNEEL: AnimationState.CROUCH,
    AnimationState.CROUCH: AnimationState.UPRIGHT
}
var try_crouch_states = { # directly pressing down
    AnimationState.UPRIGHT: AnimationState.CROUCH,
    AnimationState.CROUCH: AnimationState.KNEEL,
    AnimationState.SIT: AnimationState.CRAWL
}


@export_category("Node References")
@export var ragdoll_animator: DollActiveRagdollAnimator
@export var input_handler: DollInputHandler
@export var movement_controller: DollMovementController
@export var procedural_renderer: DollProceduralRenderer
