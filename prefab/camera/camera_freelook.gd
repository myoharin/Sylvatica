extends Camera2D

@export_range(10,100) var speed: int = 20 # pixel/second

func _process(delta: float) -> void:

	if Input.is_action_pressed("ui_right"):
		position.x += speed*delta
		#print("camera moved right")
	if Input.is_action_pressed("ui_left"):
		position.x -= speed*delta
		#print("camera moved left")
	if Input.is_action_pressed("ui_down"):
		position.y += speed*delta
		#print("camera moved down")
	if Input.is_action_pressed("ui_up"):
		position.y -= speed*delta
		#print("camera moved up")
	#print(position)

