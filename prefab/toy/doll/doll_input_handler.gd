# can support up to 4 input source
class_name DollInputHandler
extends Node
@export var doll: Doll
@export var movement_controller: DollMovementController
@export_range(1,4) var input_id: int = 1

@export_category("Input Buffer Times: just_pressed | just_released | held | tapped")
@export var right_buffer_frames: Vector4i = Vector4i(10, 10, 0, 5) # frames
@export var left_buffer_frames: Vector4i = Vector4i(10, 10, 0, 5) # frames
@export var up_buffer_frames: Vector4i = Vector4i(5, 5, 0, 5) # frames
@export var down_buffer_frames: Vector4i = Vector4i(5, 5, 0, 5) # frames
@export var jump_buffer_frames: Vector4i = Vector4i(5, 5, 0, 5) # frames

@export var input_tapped_threshold: int = 10 # frames, 60 frames/second
@export var input_update_frames: int = 60 # update input by this physics frame.

# On ready variables (order matters)

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

var time_since_last_update: int = 0


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
func _process(_delta: float) -> void:
    if Input.is_action_pressed("test_4"): # check buffer left
        print("Right Buffers: ", right_buffers)
        print("Left Buffers: ", left_buffers)
        print("Up Buffers: ", up_buffers)
        print("Down Buffers: ", down_buffers)
        print("Jump Buffers: ", jump_buffers)

        print("Right Held Time: ", right_held_time)
        print("Left Held Time: ", left_held_time)
        print("Up Held Time: ", up_held_time)
        print("Down Held Time: ", down_held_time)
        print("Jump Held Time: ", jump_held_time)

func update_buffers() -> void:   
    # set up
    right_buffers.x = max(right_buffers.x, right_buffer_frames.x * int(
        Input.is_action_just_pressed(right_input_name)))
    right_buffers.y = max(right_buffers.y, right_buffer_frames.y * int(
        Input.is_action_just_released(right_input_name)))
    right_buffers.z = max(right_buffers.z, right_buffer_frames.z * int(
        Input.is_action_pressed(right_input_name)))
    right_buffers.w = max(right_buffers.w, right_buffer_frames.w * int(
        right_held_time <= input_tapped_threshold) * int(
        right_buffers.y > 0)) # tapped is a subset of just released

    left_buffers.x = max(left_buffers.x, left_buffer_frames.x * int(
        Input.is_action_just_pressed(left_input_name)))
    left_buffers.y = max(left_buffers.y, left_buffer_frames.y * int(
        Input.is_action_just_released(left_input_name)))
    left_buffers.z = max(left_buffers.z, left_buffer_frames.z * int(
        Input.is_action_pressed
        (left_input_name)))
    left_buffers.w = max(left_buffers.w, left_buffer_frames.w * int(
        left_held_time <= input_tapped_threshold) * int(
        left_buffers.y > 0)) # tapped is a subset of just released
    
    up_buffers.x = max(up_buffers.x, up_buffer_frames.x * int(
        Input.is_action_just_pressed(up_input_name)))
    up_buffers.y = max(up_buffers.y, up_buffer_frames.y * int(
        Input.is_action_just_released(up_input_name)))
    up_buffers.z = max(up_buffers.z, up_buffer_frames.z * int(
        Input.is_action_pressed(up_input_name)))
    up_buffers.w = max(up_buffers.w, up_buffer_frames.w * int(
        up_held_time <= input_tapped_threshold) * int(
        up_buffers.y > 0)) # tapped is a subset of just released

    down_buffers.x = max(down_buffers.x, down_buffer_frames.x * int(
        Input.is_action_just_pressed(down_input_name)))
    down_buffers.y = max(down_buffers.y, down_buffer_frames.y * int(
        Input.is_action_just_released(down_input_name)))
    down_buffers.z = max(down_buffers.z, down_buffer_frames.z * int(
        Input.is_action_pressed(down_input_name)))
    down_buffers.w = max(down_buffers.w, down_buffer_frames.w * int(
        down_held_time <= input_tapped_threshold) * int(
        down_buffers.y > 0)) # tapped is a subset of just released

    jump_buffers.x = max(jump_buffers.x, jump_buffer_frames.x * int(
        Input.is_action_just_pressed(jump_input_name)))
    jump_buffers.y = max(jump_buffers.y, jump_buffer_frames.y * int(
        Input.is_action_just_released(jump_input_name)))
    jump_buffers.z = max(jump_buffers.z, jump_buffer_frames.z * int(
        Input.is_action_pressed(jump_input_name)))  
    jump_buffers.w = max(jump_buffers.w, jump_buffer_frames.w * int(
        jump_held_time <= input_tapped_threshold) * int(
        jump_buffers.y > 0)) # tapped is a subset of just released

func _input(_event: InputEvent) -> void:
    time_since_last_update = 0
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
    right_held_time *= int(right_just_pressed or right_held or right_just_released)
    left_held_time *= int(left_just_pressed or left_held or left_just_released)
    up_held_time *= int(up_just_pressed or up_held or up_just_released)
    down_held_time *= int(down_just_pressed or down_held or down_just_released)
    jump_held_time *= int(jump_just_pressed or jump_held or jump_just_released)


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

    # detect try roll - hard fall or kneel
    if down_held and (right_held or left_held):
        movement_controller.try_roll()

    # up down state changes (tapped(just released) or held)
    if down_tapped or (down_held_time > input_tapped_threshold):
        movement_controller.try_crouch(down_held_time > input_tapped_threshold)
    if up_tapped or (up_held_time > input_tapped_threshold):
        movement_controller.try_stand(up_held_time > input_tapped_threshold)

func _physics_process(_delta: float) -> void:
    time_since_last_update += 1
    if time_since_last_update >= input_update_frames:
        _input(null)


    # count down buffers
    right_buffers.x -= int(right_buffers.x > 0)
    left_buffers.x -= int(left_buffers.x > 0)
    up_buffers.x -= int(up_buffers.x > 0)
    down_buffers.x -= int(down_buffers.x > 0)
    jump_buffers.x -= int(jump_buffers.x > 0)

    right_buffers.y -= int(right_buffers.y > 0)
    left_buffers.y -= int(left_buffers.y > 0)
    up_buffers.y -= int(up_buffers.y > 0)
    down_buffers.y -= int(down_buffers.y > 0)
    jump_buffers.y -= int(jump_buffers.y > 0)

    right_buffers.z -= int(right_buffers.z > 0)
    left_buffers.z -= int(left_buffers.z > 0)
    up_buffers.z -= int(up_buffers.z > 0)
    down_buffers.z -= int(down_buffers.z > 0)
    jump_buffers.z -= int(jump_buffers.z > 0)

    right_buffers.w -= int(right_buffers.w > 0)
    left_buffers.w -= int(left_buffers.w > 0)
    up_buffers.w -= int(up_buffers.w > 0)
    down_buffers.w -= int(down_buffers.w > 0)
    jump_buffers.w -= int(jump_buffers.w > 0)
    jump_buffers.x -= int(jump_buffers.x > 0)

    # update held time
    right_held_time += 1 * int(Input.is_action_pressed(right_input_name))
    left_held_time += 1 * int(Input.is_action_pressed(left_input_name))
    up_held_time += 1 * int(Input.is_action_pressed(up_input_name))
    down_held_time += 1 * int(Input.is_action_pressed(down_input_name))
    jump_held_time += 1 * int(Input.is_action_pressed(jump_input_name))
