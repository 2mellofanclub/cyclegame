extends Node

var in_menu := true


func _ready():
	$LevelController.start_main_menu()


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and not in_menu:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
