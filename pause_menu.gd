extends Control

enum MENU_STATE {PAUSE, CONTINUE, SETTINGS, MAIN, EXIT}

var level_controller : Node3D
var current_menu_state : MENU_STATE


func go_back():
	match current_menu_state:
		MENU_STATE.PAUSE:
			change_menu_state(MENU_STATE.CONTINUE)
		MENU_STATE.SETTINGS:
			change_menu_state(MENU_STATE.PAUSE)
	
func change_menu_state(state: MENU_STATE):
	current_menu_state = state
	for child in $PauseCenterContainer.get_children():
		child.hide()
	match state:
		MENU_STATE.PAUSE:
			$PauseCenterContainer/Pause.show()
		MENU_STATE.CONTINUE:
			SignalBus.pause_toggled.emit()
		MENU_STATE.SETTINGS:
			pass
		MENU_STATE.MAIN:
			SignalBus.pause_toggled.emit()
			level_controller.start_main_menu()
		MENU_STATE.EXIT:
			get_tree().quit()
