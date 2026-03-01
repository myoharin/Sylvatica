class_name Doll
extends Node2D

# centralise enum reference
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

@export_category("Node References")
@export var ragdoll_animator: DollActiveRagdollAnimator
@export var input_handler: DollInputHandler
@export var movement_controller: DollMovementController
@export var procedural_renderer: DollProceduralRenderer