extends Node


func _ready():
	#$LevelController.start_new_level("res://levels/grid.tscn")
	#await get_tree().create_timer(30).timeout
	#$LevelController.start_new_level("res://levels/one_v_one.tscn")
	$LevelController.start_new_level("res://levels/the_range.tscn")
	

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
