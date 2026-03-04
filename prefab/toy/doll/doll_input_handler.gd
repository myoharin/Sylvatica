# can support up to 4 input source
class_name DollInputHandler
extends Node
@export var doll: Doll
@export var movement_controller: DollMovementController
@export_range(1,4) var input_id: int = 1

@export_category("Input Buffer Times: just_pressed | just_released | held")
@export var right_buffer_frames: Vector3i = Vector3i(5, 5, 5) # frames
@export var left_buffer_frames: Vector3i = Vector3i(5, 5, 5) # frames
@export var up_buffer_frames: Vector3i = Vector3i(5, 5, 5) # frames
@export var down_buffer_frames: Vector3i = Vector3i(5, 5, 5) # frames
@export var jump_buffer_frames: Vector3i = Vector3i(5, 5, 5) # frames

# input buffers, representing just_pressed, just_released, held - count down at _PhysicsProcess
var right_buffers: Vector3i = Vector3i.ZERO # just_pressed, just_released, held
var left_buffers: Vector3i = Vector3i.ZERO # just_pressed, just_released, held
var up_buffers: Vector3i = Vector3i.ZERO # just_pressed, just_released, held
var down_buffers: Vector3i = Vector3i.ZERO # just_pressed, just_released, held
var jump_buffers: Vector3i = Vector3i.ZERO # just_pressed, just_released, held

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
    var input_prefix = "input_" + str(input_id) + "_"   
    # set up
    right_buffers.x = right_buffer_frames.x * int(
        Input.is_action_just_pressed(input_prefix + "right"))
    right_buffers.y = right_buffer_frames.y * int(
        Input.is_action_just_released(input_prefix + "right"))
    right_buffers.z = right_buffer_frames.z * int(
        Input.is_action_pressed(input_prefix + "right"))

    left_buffers.x = left_buffer_frames.x * int(
        Input.is_action_just_pressed(input_prefix + "left"))
    left_buffers.y = left_buffer_frames.y * int(
        Input.is_action_just_released(input_prefix + "left"))
    left_buffers.z = left_buffer_frames.z * int(
        Input.is_action_pressed
        (input_prefix + "left"))
    
    up_buffers.x = up_buffer_frames.x * int(
        Input.is_action_just_pressed(input_prefix + "up"))
    up_buffers.y = up_buffer_frames.y * int(
        Input.is_action_just_released(input_prefix + "up"))
    up_buffers.z = up_buffer_frames.z * int(
        Input.is_action_pressed(input_prefix + "up"))

    down_buffers.x = down_buffer_frames.x * int(
        Input.is_action_just_pressed(input_prefix + "down"))
    down_buffers.y = down_buffer_frames.y * int(
        Input.is_action_just_released(input_prefix + "down"))
    down_buffers.z = down_buffer_frames.z * int(
        Input.is_action_pressed(input_prefix + "down"))

    jump_buffers.x = jump_buffer_frames.x * int(
        Input.is_action_just_pressed(input_prefix + "jump"))
    jump_buffers.y = jump_buffer_frames.y * int(
        Input.is_action_just_released(input_prefix + "jump"))
    jump_buffers.z = jump_buffer_frames.z * int(
        Input.is_action_pressed(input_prefix + "jump"))

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

    var right_pressed = bool(right_buffers.z)
    var left_pressed = bool(left_buffers.z)
    var up_pressed = bool(up_buffers.z)
    var down_pressed = bool(down_buffers.z)
    var jump_pressed = bool(jump_buffers.z)

    # detect continous horizontal movement via is_action_pressed
    movement_controller.facing_direction = int(right_pressed) - int(left_pressed)
    movement_controller.try_walk_right = right_pressed
    movement_controller.try_walk_left = left_pressed

    # detect turn / initiate jump via is_action_just_pressed
    if jump_just_pressed: # NOTDONE
        pass
    if right_just_pressed and left_pressed: # NOTDONE
        pass
    if left_just_pressed: # NOTDONE
        pass

    # detect / limit jump height
    if jump_pressed: # NOTDONE
        pass
    if jump_just_released: # NOTDONE
        pass

        # detect try roll

func _physics_process(_delta: float) -> void:
    # count down buffers
    right_buffers -= Vector3i.ONE * int(right_buffers.x > 0)
    left_buffers -= Vector3i.ONE * int(left_buffers.x > 0)
    up_buffers -= Vector3i.ONE * int(up_buffers.x > 0)
    down_buffers -= Vector3i.ONE * int(down_buffers.x > 0)
    jump_buffers -= Vector3i.ONE * int(jump_buffers.x > 0)
