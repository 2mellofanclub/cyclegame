extends Control

enum MENU_STATE {MAIN, MODES, SETTINGS, CREDITS, EXIT, SAVES, GARAGE, CW_LEVELS, DH_LEVELS, SURV_LEVELS}

var level_controller : Node3D
var current_menu_state : MENU_STATE


func _ready() -> void:
	change_menu_state(MENU_STATE.MAIN)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func go_back():
	match current_menu_state:
		MENU_STATE.MODES:
			change_menu_state(MENU_STATE.MAIN)
		MENU_STATE.SETTINGS:
			change_menu_state(MENU_STATE.MAIN)
		MENU_STATE.CREDITS:
			change_menu_state(MENU_STATE.MAIN)
		MENU_STATE.GARAGE:
			change_menu_state(MENU_STATE.MODES)
		MENU_STATE.CW_LEVELS:
			change_menu_state(MENU_STATE.MODES)
		MENU_STATE.DH_LEVELS:
			change_menu_state(MENU_STATE.MODES)
		MENU_STATE.SURV_LEVELS:
			change_menu_state(MENU_STATE.MODES)


func change_menu_state(state : MENU_STATE):
	current_menu_state = state
	$Back.show()
	#for child in $SideContainer/MarginContainer.get_children():
		#child.hide()
	for child in $MainCenterContainer.get_children():
		child.hide()
	match state:
		MENU_STATE.MAIN:
			$Back.hide()
			$MainCenterContainer/MainControls.show()
		MENU_STATE.MODES:
			$MainCenterContainer/Modes.show()
		MENU_STATE.SETTINGS:
			pass
		MENU_STATE.CREDITS:
			pass
		MENU_STATE.EXIT:
			get_tree().quit()
		MENU_STATE.GARAGE:
			start_level("res://levels/garage.tscn")
		MENU_STATE.CW_LEVELS:
			$MainCenterContainer/CycleWarLevels.show()
		MENU_STATE.DH_LEVELS:
			$MainCenterContainer/DataHuntLevels.show()
		MENU_STATE.SURV_LEVELS:
			$MainCenterContainer/SurvivalLevels.show()


func start_level(path : String):
	level_controller.start_new_level(path)
