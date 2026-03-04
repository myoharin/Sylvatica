class_name DollMovementController extends Node
# node 2D is used here so the character can be used in scene
# base node 2D should NEVER be used

@export_group("Reference Nodes")
@export var doll: Doll
# - Detecting Collision
@export var head: RigidBody2D 
@export var torso: RigidBody2D
@export var feet: RigidBody2D
# other modules
@export var animator: DollActiveRagdollAnimator
# - Dominating Character
@export var character_body: CharacterBody2D

@export_category("Movement Parameters")
@export_group("Movent State Parameters")
@export var movement_roll_count: int = 3
@export var movement_turning_time: float = 0.5 # seconds
@export var movement_dodging_time: float = 0.5 # seconds
@export var movement_hard_landing_time: float = 0.5 # seconds
@export var movement_stationary_threshold: float = 10 # pixel/second
@export var coyote_time: float = 0.2 # seconds

@export_group("Walking Parameters")
@export var movement_walk_speed: float = 100 # pixel/second
@export var movement_walk_acceleration_weight: float = 0.5

@export_group("Jump Derivatives Parameters")
@export var base_jump_strength: float = 100 # initial impulse
# - acceleration impulse in arbitrary unites, multiplying by the above
@export var flip_velocity: Vector2 = Vector2(0,2)
@export var hop_velocity: Vector2 = Vector2(0,1)
@export var pounce_velocity: Vector2 = Vector2(2,0.5)
@export var prance_velocity: Vector2 = Vector2(1.5,1)


# internal variables

# - Jump Types
enum JumpState {
    NONE, # when no jumps are initiated
    FLIP, # spin jump
    HOP, # standing jump with no momentum, valuing maintaing stability
    POUNCE, # crawl jump
    PRANCE, # standing jump ADDING momentum, valuing speed
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

var facing_direction: int = doll.FacingDirection.NEUTRAL
var jump_state: JumpState = JumpState.NONE
var proactive_movement_speed: Vector2 = Vector2.ZERO
# proactive movement speed includes: walking / jumping
# does not include not proactive ones like knockback, hard landing

# Movement States: should never be set directly, only via functions

# - basic movement states

func is_in_motion() -> bool:
    return character_body.velocity.length() > movement_stationary_threshold
func is_walking() -> bool:
    # is on ground
    # is moving
    # need to implement coyote time
    return is_coyote_ground and is_in_motion()
func is_tapping_wall() -> bool: # NOTDONE
    # feet touching wall

    # can tap jump off of walls
    return false
func is_clinging_wall() -> bool: # NOTDONE
    # feet and torso touching wall

    # can tap cling and slide slowly against walls
    return false

# - togglable timed movement states
# - - only handles its boolean and timeout
var is_turning: bool = false
var is_dodging: bool = false
var is_hard_landed: bool = false
var is_coyote_ground: bool = false

func trigger_is_turn(duration: float = movement_turning_time):
    is_turning = true
    await get_tree().create_timer(duration).timeout
    is_turning = false
func trigger_is_dodge(duration: float = movement_dodging_time):
    is_dodging = true
    await get_tree().create_timer(duration).timeout
    is_dodging = false
func trigger_is_hard_land(duration: float = movement_hard_landing_time):
    is_hard_landed = true
    await get_tree().create_timer(duration).timeout
    is_hard_landed = false
func trigger_coyote_time(duration: float = coyote_time):
    is_coyote_ground = true
    await get_tree().create_timer(duration).timeout
    is_coyote_ground = false

# - Others
func is_flipping() -> bool:
    return animator.animation_state == AnimationState.FLIP
func is_rolling() -> bool:
    return animator.animation_state == AnimationState.ROLL

# Init

func _init() -> void:
    pass

#  process

func _process(_delta: float) -> void:
    if Input.is_action_pressed("test_3"):
        print("Walking Right: ", try_walk_right)
        print("Walking Left: ", try_walk_left)
        print("Facing Direction: ", facing_direction)


func _physics_process(_delta: float) -> void: # grand controller
    # state checking
    if character_body.is_on_floor():
        trigger_coyote_time()

    # walk speed
    character_body.velocity = character_body.velocity.lerp(
        Vector2(
            facing_direction * movement_walk_speed, # determines direction
            character_body.velocity.y),
        movement_walk_acceleration_weight) # acceleration

    # movement
    character_body.velocity = proactive_movement_speed
    character_body.move_and_slide()
    
    
# MovementController
# - Controller Try
    # called by input handler, these functions that is
    # all jump related input is handled by try jump
    # operate at the _input() speed level.

var try_walk_right: bool = false
var try_walk_left: bool = false

func try_up(): # NOTDONE
    pass
    # climb up
    # 
func try_down(): # NOTDONE
    pass
    # including diving down.
    # crouch -> sit / kneel -> crawl
func try_jump(direction_held: bool, direction: int = facing_direction): # NOTDONE
    pass
    # try_flip
        # requires have enough jumps left + turning state

    # try_hop
        # requires have enough jumps left

    # try_pounce
        # requires have enough jumps left + 
        # crouching() + on ground +
        # direction held 
        
    # try_prance
        # requires have enough jumps left + get_is_walking()
        # direction held 

    # try_roll
        # requires touching ground + hard land

func instant_turn():
    # called by input controller directly, easier to detect on input end.
    trigger_is_turn()


# - Sub Try functions
    # called by controller functions mostly.

# - Instant Movement Triggers: called by functions when criteria is fulfilled / shortcuts
    # should be indepent of input / external factors, but can require parameters.
    # this should also be where the animation call is placed.
    # overall information flow is input -> movement_controller -> ragdoll_animate -> render_animate
func instant_flip(direction: int = facing_direction): # NOTDONE
    pass
func instant_hop(direction: int = facing_direction): # NOTDONE
    pass
func instant_pounce(direction: int = facing_direction): # NOTDONE
    pass
func instant_prance(direction: int = facing_direction): # NOTDONE
    pass
func instant_roll(direction: int = facing_direction): # NOTDONE
    pass
