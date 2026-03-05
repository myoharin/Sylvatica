# can support up to 4 input source
class_name DollInputHandler
extends Node
@export var doll: Doll
@export var movement_controller: DollMovementController
@export_range(1,4) var input_id: int = 1

@export_category("Input Buffer Times: just_pressed | just_released | held | tapped")
@export var right_buffer_frames: Vector4i = Vector4i(30, 30, 0, 15) # frames
@export var left_buffer_frames: Vector4i = Vector4i(30, 30, 0, 15) # frames
@export var up_buffer_frames: Vector4i = Vector4i(15, 15, 0, 15) # frames
@export var down_buffer_frames: Vector4i = Vector4i(15, 15, 0, 15) # frames
@export var jump_buffer_frames: Vector4i = Vector4i(15, 15, 0, 15) # frames

@export var input_tapped_threshold: int = 10 # frames, 60 frames/second

@onready var input_prefix = "input_" + str(input_id) + "_"
@onready var right_input_name = input_prefix + "right"
@onready var left_input_name = input_prefix + "left"
@onready var up_input_name = input_prefix + "up"
@onready var down_input_name = input_prefix + "down"
@onready var jump_input_name = input_prefix + "jump"

# input buffers, representing [just_pressed, just_released, held, tapped] 
# - count down at _PhysicsProcess()
var right_buffers: Vector4i = Vector4i.ZERO
var left_buffers: Vector4i = Vector4i.ZERO
var up_buffers: Vector4i = Vector4i.ZERO
var down_buffers: Vector4i = Vector4i.ZERO
var jump_buffers: Vector4i = Vector4i.ZERO

# held time, used for estimating taps
var right_held_time: int = 0
var left_held_time: int = 0
var up_held_time: int = 0
var down_held_time: int = 0
var jump_held_time: int = 0



# which control group it is supposed to accept from. maximum of 4 control groups

enum InputType {
    LEFT,
    RIGHT,
    UP,
    DOWN,
    JUMP
}
var input_type_strings = {
    InputType.LEFT: "left",
    InputType.RIGHT: "right",
    InputType.UP: "up",
    InputType.DOWN: "down",
    InputType.JUMP: "jump"
}

# other variable
var try_turning_left: bool = false # true when just pressed + is pressed in opposite direction
var try_turning_right: bool = false


# control input
func update_buffers() -> void:   
    # set up
    right_buffers.x = right_buffer_frames.x * int(
        Input.is_action_just_pressed(right_input_name))
    right_buffers.y = right_buffer_frames.y * int(
        Input.is_action_just_released(right_input_name))
    right_buffers.z = right_buffer_frames.z * int(
        Input.is_action_pressed(right_input_name))
    right_buffers.w = right_buffer_frames.w * int(
        right_held_time <= input_tapped_threshold) * int(right_buffers.y > 0)

    left_buffers.x = left_buffer_frames.x * int(
        Input.is_action_just_pressed(left_input_name))
    left_buffers.y = left_buffer_frames.y * int(
        Input.is_action_just_released(left_input_name))
    left_buffers.z = left_buffer_frames.z * int(
        Input.is_action_pressed
        (left_input_name))
    left_buffers.w = left_buffer_frames.w * int(
        left_held_time <= input_tapped_threshold) * int(left_buffers.y > 0)
    
    up_buffers.x = up_buffer_frames.x * int(
        Input.is_action_just_pressed(up_input_name))
    up_buffers.y = up_buffer_frames.y * int(
        Input.is_action_just_released(up_input_name))
    up_buffers.z = up_buffer_frames.z * int(
        Input.is_action_pressed(up_input_name))
    up_buffers.w = up_buffer_frames.w * int(
        up_held_time <= input_tapped_threshold) * int(up_buffers.y > 0)

    down_buffers.x = down_buffer_frames.x * int(
        Input.is_action_just_pressed(down_input_name))
    down_buffers.y = down_buffer_frames.y * int(
        Input.is_action_just_released(down_input_name))
    down_buffers.z = down_buffer_frames.z * int(
        Input.is_action_pressed(down_input_name))
    down_buffers.w = down_buffer_frames.w * int(
        down_held_time <= input_tapped_threshold) * int(down_buffers.y > 0)

    jump_buffers.x = jump_buffer_frames.x * int(
        Input.is_action_just_pressed(jump_input_name))
    jump_buffers.y = jump_buffer_frames.y * int(
        Input.is_action_just_released(jump_input_name))
    jump_buffers.z = jump_buffer_frames.z * int(
        Input.is_action_pressed(jump_input_name))
    jump_buffers.w = jump_buffer_frames.w * int(
        jump_held_time <= input_tapped_threshold) * int(jump_buffers.y > 0)

func _input(_event: InputEvent) -> void:
    # set up
    # update buffers in _input to track just pressed and just released accurately
    update_buffers()

    var right_just_pressed = bool(right_buffers.x)
    var left_just_pressed = bool(left_buffers.x)
    var up_just_pressed = bool(up_buffers.x)
    var down_just_pressed = bool(down_buffers.x)
    var jump_just_pressed = bool(jump_buffers.x)

    var right_just_released = bool(right_buffers.y)
    var left_just_released = bool(left_buffers.y)
    var up_just_released = bool(up_buffers.y)
    var down_just_released = bool(down_buffers.y)
    var jump_just_released = bool(jump_buffers.y)

    var right_held = bool(right_buffers.z)
    var left_held = bool(left_buffers.z)
    var up_held = bool(up_buffers.z)
    var down_held = bool(down_buffers.z)
    var jump_held = bool(jump_buffers.z)

    var right_tapped = bool(jump_buffers.w)
    var left_tapped = bool(left_buffers.w)
    var up_tapped = bool(up_buffers.w)
    var down_tapped = bool(down_buffers.w)
    var jump_tapped = bool(jump_buffers.w)

    # detect continous horizontal movement via is_action_held
    movement_controller.try_face_direction(int(right_held) - int(left_held))
    movement_controller.try_walk_direction = int(right_held) - int(left_held)
    movement_controller.try_walk = right_held or left_held

    # manage held time resets
    right_held_time *= int(right_just_pressed) * int(right_just_released)
    left_held_time *= int(left_just_pressed) * int(left_just_released)
    up_held_time *= int(up_just_pressed) * int(up_just_released)
    down_held_time *= int(down_just_pressed) * int(down_just_released)
    jump_held_time *= int(jump_just_pressed) * int(jump_just_released)


    # detect turn / initiate jump via is_action_just_pressed
    if jump_just_pressed:
        movement_controller.try_jump( # direction_held
            right_held or left_held
        )
    if (right_just_pressed and left_just_released) or (
        left_just_pressed and right_just_released
    ):
        movement_controller.try_turn()

    # limit jump height
    if jump_just_released: # NOTDONE
        movement_controller.try_release_jump()

    # detect try roll
    if down_held and (right_held or left_held):
        movement_controller.try_roll()

    # up down state changes
    if down_just_pressed or down_held:
        movement_controller.try_crouch(down_held)
    if up_just_pressed or up_held:
        movement_controller.try_stand(up_held)
    

func _physics_process(_delta: float) -> void:
    # count down buffers
    right_buffers -= Vector4i.ONE * int(right_buffers.x > 0)
    left_buffers -= Vector4i.ONE * int(left_buffers.x > 0)
    up_buffers -= Vector4i.ONE * int(up_buffers.x > 0)
    down_buffers -= Vector4i.ONE * int(down_buffers.x > 0)
    jump_buffers -= Vector4i.ONE * int(jump_buffers.x > 0)

    # update held time
    right_held_time += 1 * int(Input.is_action_pressed(right_input_name))
    left_held_time += 1 * int(Input.is_action_pressed(left_input_name))
    up_held_time += 1 * int(Input.is_action_pressed(up_input_name))
    down_held_time += 1 * int(Input.is_action_pressed(down_input_name))
    jump_held_time += 1 * int(Input.is_action_pressed(jump_input_name))
