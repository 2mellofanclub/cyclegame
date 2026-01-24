extends Node


func _ready():
	PlayerData.load_game()
	$LevelController.start_main_menu()
	$PauseMenu.level_controller = $LevelController
	$LevelController.pause_menu = $PauseMenu


func _process(_delta):
	pass
