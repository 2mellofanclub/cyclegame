extends Node


func _ready():
	PlayerData.load_game()
	$LevelController.start_main_menu()
	$PauseMenu.level_controller = $LevelController
	SignalBus.pause_toggled.connect(toggle_pause)


func _process(delta):
	pass


func toggle_pause():
	if not get_tree().paused:
		get_tree().paused = true
		$PauseMenu.change_menu_state(0)
		$PauseMenu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$PauseMenu.hide()
		get_tree().paused = false
