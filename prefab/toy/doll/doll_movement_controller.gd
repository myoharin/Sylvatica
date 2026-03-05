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
@export var movement_turning_frames: int = 20 # frames
@export var movement_dodging_frames: int = 40 # frames
@export var movement_hard_landing_frames: int = 20 # frames
@export var movement_stationary_threshold: float = 10 # pixel/second
@export var coyote_frames: int = 12 # frames
@export var movement_crouch_stand_cooldown_frames: int = 30 # frames

@export_group("Walking Parameters")
@export var movement_walk_speed: float = 200 # pixel/second
@export var movement_walk_acceleration_speed: float = 2 # lerp(1/2)/second

@export_group("Jump Derivatives Parameters")
@export var base_jump_strength: float = 300 # initial impulse
# - acceleration impulse in arbitrary unites, multiplying by the above
@export var flip_velocity: Vector2 = Vector2(0,2)
@export var hop_velocity: Vector2 = Vector2(0,1)
@export var pounce_velocity: Vector2 = Vector2(2,0.5)
@export var prance_velocity: Vector2 = Vector2(1.5,1)


var try_stand_states = {
        animator.AnimationState.CRAWL: animator.AnimationState.SIT,
        animator.AnimationState.SIT: animator.AnimationState.CROUCH,
        animator.AnimationState.KNEEL: animator.AnimationState.CROUCH,
        animator.AnimationState.CROUCH: animator.AnimationState.UPRIGHT
    }
var try_crouch_states = { # directly pressing down
        animator.AnimationState.UPRIGHT: animator.AnimationState.CROUCH,
        animator.AnimationState.CROUCH: animator.AnimationState.KNEEL,
        animator.AnimationState.SIT: animator.AnimationState.CRAWL
    }

# internal variables

# - Jump Types
enum JumpState {
    NONE, # when no jumps are initiated
    FLIP, # spin jump
    HOP, # standing jump with no momentum, valuing maintaing stability
    POUNCE, # crawl jump
    PRANCE, # standing jump ADDING momentum, valuing speed
}

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
var is_turning_frames: int = 0
var is_dodging_frames: int = 0
var is_hard_landed_frames: int = 0
var is_coyote_ground_frames: int = 0
var crouch_stand_cooldown_frames: int = 0

func is_turning() -> bool:
    return is_turning_frames > 0
func is_dodging() -> bool:
    return is_dodging_frames > 0
func is_hard_landed() -> bool:
    return is_hard_landed_frames > 0
func is_coyote_ground() -> bool:
    return is_coyote_ground_frames > 0
func is_crouch_stand_cooled() -> bool:
    return crouch_stand_cooldown_frames <= 0

func trigger_is_turn(duration: int = movement_turning_frames):
    is_turning_frames = duration
func trigger_is_dodge(duration: int = movement_dodging_frames):
    is_dodging_frames = duration
func trigger_is_hard_land(duration: int = movement_hard_landing_frames):
    is_hard_landed_frames = duration
func trigger_coyote_time(duration: int = coyote_frames):
    is_coyote_ground_frames = duration
func trigger_crouch_stand_cooldown(duration: int = movement_crouch_stand_cooldown_frames):
    crouch_stand_cooldown_frames = duration

# Init

func _init() -> void:
    pass

#  process

func _process(_delta: float) -> void:
    if Input.is_action_pressed("test_3"):
        print("Walking: ", try_walk)
        print("Facing Direction: ", animator.facing_direction)
        print("Last Facing Direction: ", animator.last_facing_direction)
        print("Body Velocity: ", character_body.velocity)
        print("Coyote Ground: ", is_coyote_ground())

    if is_turning():
        print("Turning! " + str(is_turning_frames))
    if is_dodging():
        print("Dodging! " + str(is_dodging_frames))
    if is_hard_landed():
        print("Hard Landed! " + str(is_hard_landed_frames))


func _physics_process(_delta: float) -> void: # grand controller
    # state checking
    if character_body.is_on_floor():
        trigger_coyote_time()
        character_body.velocity.y = 0

    # state timers
    is_turning_frames -= 1 * int(is_turning())
    is_dodging_frames -= 1 * int(is_dodging())
    is_hard_landed_frames -= 1 * int(is_hard_landed())
    is_coyote_ground_frames -= 1 * int(is_coyote_ground())
    movement_crouch_stand_cooldown_frames -= 1 * int(not is_crouch_stand_cooled())

    # movement
    accelerate_character_velocities_half(_delta)
    character_body.move_and_slide()
    accelerate_character_velocities_half(_delta)

func accelerate_character_velocities_half(_delta: float) -> void:
    # header - seperate velocity applications
    character_body.velocity -= proactive_movement_speed

    # - gravity
    character_body.velocity += character_body.get_gravity() * _delta * 0.3

    # - walk speed
    proactive_movement_speed = character_body.velocity.lerp(
        Vector2(
            try_walk_direction * movement_walk_speed * int(try_walk), # determines direction
            character_body.velocity.y),
        pow(0.5, _delta * movement_walk_acceleration_speed)) # lerp-acceleration


    # footer - seperate velocity applications
    character_body.velocity += proactive_movement_speed
    

    
    
# MovementController
# - Controller Try
    # called by input handler, these functions that is
    # all jump related input is handled by try jump
    # operate at the _input() speed level.

var try_walk: bool = false
var try_walk_direction: int = doll.FacingDirection.RIGHT

func try_face_direction(direction: int) -> void:
    var success: bool = animator.unturnable_states.has(animator.animation_state)
    # booleanise if statement
    animator.facing_direction = direction * int(success) + (
        animator.facing_direction * int(not success))

func try_stand(_up_held: bool): # NOTDONE - held interaction
    # state change change
    if is_crouch_stand_cooled() and try_stand_states.has(animator.animation_state):
        if animator.animation_state == animator.AnimationState.CRAWL:
            animator.facing_direction *= -1
        animator.change_animation_state(try_stand_states[animator.animation_state])
        trigger_crouch_stand_cooldown()

func try_crouch(_down_held: bool): # NOTDONE - held interaction
    # crouch -> sit / kneel -> crawl
    if is_crouch_stand_cooled() and try_crouch_states.has(animator.animation_state):
        if animator.animation_state == animator.AnimationState.SIT:
            animator.facing_direction *= -1
        animator.change_animation_state(try_crouch_states[animator.animation_state])
        trigger_crouch_stand_cooldown()

func try_release_jump(): # NOTDONE
    # cut existing jump action short
    # prance, standinghops and flips
    pass

func try_jump(direction_held: bool) -> void:
    # invalid jumping conditions
    if not is_coyote_ground():
        print("Failed to jump: not in coyote time")
        return
    if animator.unjumpable_states.has(animator.animation_state):
        print("Failed to jump: unjumpable state: " + str(animator.animation_state))
        return

    # try jumping
    # - flips
    if is_turning() and (animator.animation_state == animator.AnimationState.UPRIGHT): # flip
        instant_flip()
        return
    # - prance
    if direction_held and ( # prance
        animator.animation_state == animator.AnimationState.UPRIGHT): 
        instant_prance()
        return
    # - pounce
    if direction_held and ( # pounce
        (animator.animation_state == animator.AnimationState.CROUCH) or 
        (animator.animation_state == animator.AnimationState.ROLL)):
        instant_pounce()

    instant_hop() # available to Kneel, Crouch and Upright

func try_roll():
    if (character_body.is_on_floor() and is_hard_landed and animator.facing_direction != 0) or (
        animator.animation_state == animator.AnimationState.KNEEL):
        instant_roll()
    # requires touching ground + hard land

func try_turn():
    # called by input controller directly, easier to detect on input end.
    if is_coyote_ground():
        if is_turning():
            trigger_is_dodge()
        trigger_is_turn()



# - Sub Try functions
    # called by controller functions mostly.

# - Instant Movement Triggers: called by functions when criteria is fulfilled / shortcuts
    # should be indepent of input / external factors, but can require parameters.
    # this should also be where the animation call is placed.
    # overall information flow is input -> movement_controller -> ragdoll_animate -> render_animate
func instant_flip(): # NOTDONE
    print("Flip executed!")
    var flip_impulse = flip_velocity * base_jump_strength
    flip_impulse.x *= animator.facing_direction
    proactive_movement_speed += flip_impulse
    jump_state = JumpState.FLIP
    animator.change_animation_state(animator.AnimationState.FLIP)
func instant_hop(): # NOTDONE
    print("Hop executed!")
    var hop_impulse = hop_velocity * base_jump_strength
    hop_impulse.x *= animator.facing_direction
    proactive_movement_speed += hop_impulse
    jump_state = JumpState.HOP
    animator.change_animation_state(animator.AnimationState.UPRIGHT)
func instant_pounce(): # NOTDONE
    print("Pounce executed!")
    var pounce_impulse = pounce_velocity * base_jump_strength
    pounce_impulse.x *= animator.last_facing_direction
    proactive_movement_speed += pounce_impulse
    jump_state = JumpState.POUNCE
    animator.change_animation_state(animator.AnimationState.CRAWL)
func instant_prance(): # NOTDONE
    print("Prance executed!")
    var prance_impulse = prance_velocity * base_jump_strength
    prance_impulse.x *= animator.last_facing_direction
    proactive_movement_speed += prance_impulse
    jump_state = JumpState.PRANCE
    animator.change_animation_state(animator.AnimationState.UPRIGHT)

func instant_roll(): # NOTDONE
    print("Roll executed!")
    pass
