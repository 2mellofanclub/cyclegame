extends Node3D


var level_controller: Node3D
var max_trails: int
var in_intro := true
var players = []
var enemies = []
var allies = []
var recognizers = []
@export var pulse_offset := 500.0
@export var pulse_band_offset := 0.6
@export var pulse_speed_mps := 50.0

@onready var IntroCam = $CameraTwist/CameraPitch/IntroCam
@onready var PlayerTankSpawnCam = $Spawns/PlayerTanks/PlayerSpawn/SpawnCam


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gen_maze(5,5)
	#bake nav mesh

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SignalBus.pause_toggled.emit()
	
	
	if IntroCam.current:
		$CameraTwist.rotate_y(delta * PI/10)
	if in_intro and Input.is_anything_pressed():
		in_intro = false
		PlayerTankSpawnCam.current = true
		await get_tree().create_timer(0.25).timeout
		await get_tree().create_timer(3).timeout
		$SOS.play()


func gen_maze(columns : int, rows : int):
	#region maze base
	var width = 2 * columns + 1
	var length = 2 * rows + 1
	var maze_base = []
	for y in range(0, length):
		var row = []
		for x in range(0, width):
			row.append(" ")
		maze_base.append(row)
	for y in range(0, length):
		for x in range(0, width):
			if x % 2 == 0 and y % 2 == 0:
				maze_base[y][x] = "+"
			elif x % 2 == 0:
				maze_base[y][x] = "|"
			elif y % 2 == 0:
				maze_base[y][x] = "-"
	#endregion
	var queue = []
	var visited = []
	var cell_y = 1
	var cell_x = randi_range(0,columns-1) * 2 + 1
	maze_base[cell_y][cell_x] = "?"
	queue.push_back([cell_y, cell_x])
	
	while len(queue) > 0:
		visited.append([cell_y, cell_x])
		var neighbors = []
		if cell_x+2 <= width-2:
			neighbors.append([cell_y, cell_x+2])
		if cell_x-2 > 1:
			neighbors.append([cell_y, cell_x-2])
		if cell_y+2 <= length-2:
			neighbors.append([cell_y+2, cell_x])
		if cell_y-2 > 1:
			neighbors.append([cell_y-2, cell_x])
		var unvisited_neighbors = []
		for n in neighbors:
			if not visited.has(n):
				unvisited_neighbors.append(n)
		if len(unvisited_neighbors) > 0:
			var neighbor = neighbors.pick_random()
			if neighbor[0] == cell_y:
				if neighbor[1] > cell_x:
					maze_base[cell_y][cell_x+1] = " "
				else:
					maze_base[cell_y][cell_x-1] = " "
			else:
				if neighbor[0] > cell_y:
					maze_base[cell_y+1][cell_x] = " "
				else:
					maze_base[cell_y-1][cell_x] = " "
			cell_y = neighbor[0]
			cell_x = neighbor[1]
		else:
			var queue_cell = queue.pop_front()
			cell_y = queue_cell[0]
			cell_x = queue_cell[1]
			
		for row in maze_base:
			var rowstring = ""
			for c in row:
				rowstring += c
			print(rowstring)
		print(" ")
	
	maze_base[cell_x][cell_y] = "!"
	for row in maze_base:
		var rowstring = ""
		for c in row:
			rowstring += c
		print(rowstring)
	print(" ")
		
	
