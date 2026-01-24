extends Control

enum MENU_STATE {PAUSE, CONTINUE, RESTART, SETTINGS, MAIN, EXIT}

var level_controller : Node3D
var current_menu_state : MENU_STATE


func go_back():
	print("goback")
	match current_menu_state:
		MENU_STATE.PAUSE:
			print("menustateispause")
			change_menu_state(MENU_STATE.CONTINUE)
		MENU_STATE.SETTINGS:
			print("menustateisettings")
			change_menu_state(MENU_STATE.PAUSE)
	
func change_menu_state(state: MENU_STATE):
	current_menu_state = state
	for child in $PauseCenterContainer.get_children():
		child.hide()
	match state:
		MENU_STATE.PAUSE:
			$PauseCenterContainer/Pause.show()
		MENU_STATE.CONTINUE:
			print("continue")
			SignalBus.game_unpaused.emit()
		MENU_STATE.RESTART:
			SignalBus.game_unpaused.emit()
			level_controller.restart_level()
		MENU_STATE.SETTINGS:
			pass
		MENU_STATE.MAIN:
			SignalBus.game_unpaused.emit()
			level_controller.start_main_menu()
		MENU_STATE.EXIT:
			PlayerData.save_game()
			get_tree().quit()
