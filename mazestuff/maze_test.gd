extends Node3D


@onready var maze_block_12 = load("res://mazestuff/maze_block_12.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	
	#bake nav mesh

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		SignalBus.pause_toggled.emit()
	
	if Input.is_action_just_pressed("interact"):
		for child in $MazeNavRegion/MazeBlocks.get_children():
			child.queue_free()
		var maze = []
		while maze == []:
			maze = gen_maze(12, 25)
		construct_maze(maze)


func gen_maze(columns : int, rows : int):
	#region maze base
	var width = 2 * columns + 1
	var length = 2 * rows + 1
	var maze = []
	for y in range(0, length):
		var row = []
		for x in range(0, width):
			row.append(" ")
		maze.append(row)
	for y in range(0, length):
		for x in range(0, width):
			if x % 2 == 0 and y % 2 == 0:
				maze[y][x] = "+"
			elif x % 2 == 0:
				maze[y][x] = "|"
			elif y % 2 == 0:
				maze[y][x] = "-"
	#endregion
	#region depth first search
	var queue = []
	var visited = []
	var cell_y = 1
	var cell_x = randi_range(0,columns-1) * 2 + 1
	# starting point
	maze[cell_y][cell_x] = "?"
	# break wall into maze
	maze[0][cell_x] = " "
	queue.push_back([cell_y, cell_x])
	while len(queue) > 0:
		# this makes sure cells only get added to the que once
		if not visited.has([cell_y, cell_x]):
			queue.push_back([cell_y, cell_x])
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
			#else:
				#print("fucnk")
		if len(unvisited_neighbors) > 0:
			var neighbor = neighbors.pick_random()
			if neighbor[0] == cell_y:
				if neighbor[1] > cell_x:
					maze[cell_y][cell_x+1] = " "
				else:
					maze[cell_y][cell_x-1] = " "
			else:
				if neighbor[0] > cell_y:
					maze[cell_y+1][cell_x] = " "
				else:
					maze[cell_y-1][cell_x] = " "
			cell_y = neighbor[0]
			cell_x = neighbor[1]
		else:
			var queue_cell = queue.pop_front()
			cell_y = queue_cell[0]
			cell_x = queue_cell[1]
		#for row in maze:
			#var rowstring = ""
			#for c in row:
				#rowstring += c
			#print(rowstring)
		#print(" ")
	#endregion
	#region break end wall
	var breakable_far_walls = []
	for x in range(0, width):
		if visited.has([length-2, x]):
			breakable_far_walls.append([length-1, x])
	# swear to god
	if len(breakable_far_walls) > 0:
		var exit = breakable_far_walls.pick_random()
		maze[exit[0]][exit[1]] = " "
	else:
		return []
	#endregion
	#region print final maze
	maze[cell_y][cell_x] = "!"
	for row in maze:
		var rowstring = ""
		for c in row:
			rowstring += c
		print(rowstring)
	print(" ")
	#endregion
	return maze


func construct_maze(maze):
	var empty_space_chars = ["?", " ", "!"]
	for y in len(maze):
		for x in len(maze[0]):
			if not maze[y][x] in empty_space_chars:
				var maze_block_instance = maze_block_12.instantiate()
				$MazeNavRegion/MazeBlocks.add_child(maze_block_instance)
				maze_block_instance.global_position = Vector3(
						x * 12,
						0,
						y * 12
				)
				
