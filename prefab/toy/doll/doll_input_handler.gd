# can support up to 4 input source
class_name DollInputHandler
extends Node
@export var doll: Doll
@export_range(1,4) var input_id: int = 1 
# which control group it is supposed to accept from. maximum of 4 control groups