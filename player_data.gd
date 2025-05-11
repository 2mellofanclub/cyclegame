extends Node

var big_dict_solution = {
	"chosen_cycle_color" : "blue",
	"chosen_tank_color" : "green",
	"garage_cc_index" : 0,
	"garage_tc_index" : 0,
	
	"highscores" : {
		"burning_transistor" : 0
	}
}

var save_path = "user://savegame.save"

func save_game():
	var savefile = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(big_dict_solution)
	savefile.store_line(json_string)
	print("game saved!")


func load_game():
	if not FileAccess.file_exists(save_path):
		print("The game has changed, son of Flynn!")
		return
	var savefile = FileAccess.open(save_path, FileAccess.READ)
	var json_string = savefile.get_line()
	var json = JSON.new()
	# this seemed like a good idea, so i'm just copypasteing it
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	big_dict_solution = json.data
	print("game loaded!")
	
