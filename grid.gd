extends Node3D

@onready var lightwall = preload("res://lightwallseg.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_spawn_lw():
	var lw_instance = lightwall.instantiate()
	$trails.add_child(lw_instance)
	lw_instance.global_position = $Player/trailpoint.global_position
	lw_instance.global_rotation = $Player/trailpoint.global_rotation
