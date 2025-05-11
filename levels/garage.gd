extends Node3D

var level_controller : Node3D
var max_trails: int
var in_intro := true
var players = []
var enemies = []
var allies = []
var recognizers = []

var current_mode := "cycle"
var cycle_colors := ["blue", "orange", "yellow", "green", "pink", "godwhite"]
var cc_index := 0
var tank_colors := ["blue", "orange", "green"]
var tc_index := 0
var lazy_susan := false


@onready var cycle_cam = $CamTwist/CamPitch/CycleCam
@onready var tank_cam = $CamTwist/CamPitch/TankCam
@onready var bd = PlayerData.big_dict_solution


func _ready() -> void:
	cc_index = bd["garage_cc_index"]
	tc_index = bd["garage_tc_index"]
	apply_color("cycle")
	apply_color("tank")
	switch_mode("cycle")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		lazy_susan = not lazy_susan
	if lazy_susan:
		$PlayerDummy.rotate_y(-PI/8 * delta)
		$PlayerTankDummy.rotate_y(-PI/8 * delta)


func back_to_main():
	level_controller.start_main_menu()


func switch_mode(mode : String):
	current_mode = mode
	match mode:
		"cycle":
			$PlayerTankDummy.hide()
			$Control/CycleContainer.hide()
			$Control/TankContainer.show()
			cycle_cam.make_current()
			$PlayerDummy.show()
		"tank":
			$PlayerDummy.hide()
			$Control/TankContainer.hide()
			$Control/CycleContainer.show()
			tank_cam.make_current()
			$PlayerTankDummy.show()


func change_color(direction : String):
	var increment = 1 if direction == "next" else -1
	match current_mode:
		"cycle":
			cc_index += increment
			if cc_index > (len(cycle_colors) - 1):
				cc_index = 0
			elif cc_index < 0:
				cc_index = len(cycle_colors) - 1
		"tank":
			tc_index += increment
			if tc_index > (len(tank_colors) - 1):
				tc_index = 0
			elif tc_index < 0:
				tc_index = len(tank_colors) - 1
	apply_color(current_mode)

func apply_color(mode : String):
	match mode:
		"cycle":
			$PlayerDummy.driver_color = cycle_colors[cc_index]
			$PlayerDummy.cycle_color = cycle_colors[cc_index]
			$PlayerDummy.lw_color = cycle_colors[cc_index]
			bd["chosen_cycle_color"] = cycle_colors[cc_index]
			bd["garage_cc_index"] = cc_index
			$PlayerDummy.apply_materials()
		"tank":
			$PlayerTankDummy.tank_color = tank_colors[tc_index]
			$PlayerTankDummy.shot_color = tank_colors[tc_index]
			bd["chosen_tank_color"] = tank_colors[tc_index]
			bd["garage_tc_index"] = tc_index
			$PlayerTankDummy.apply_materials()
