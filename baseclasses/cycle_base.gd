extends VehicleBody3D

class_name CycleBase

var front_steer := 1.0
var rear_steer := 0.0
var engine_power := 400.0
var max_speed := 80.0
var lw_on_th := 50.0
var lw_off_th := 15.0
var deadly_impact_th := 70.0
var kill_speed := 3.0
var qt_available := true
var driver_color := "pink"
var cycle_color := "pink"
var lw_color := "pink"
var lw_special := false
var hp := 400.0
var dead := false
var explodable := true
var controllable := false
var lw_active := false
var las_pos := Vector3.ZERO
var las_rot := Vector3.ZERO
var mouse_sens := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var level_instance: Node3D


@onready var cam_twist = $CamTwist
@onready var cam_pitch = $CamTwist/CamPitch
@onready var default_cam = $CamTwist/CamPitch/SpringArm3D/Camera3D
@onready var sbm = $sapientblockman/Armature/Skeleton3D/SBM
@onready var disc_back = $sapientblockman/Armature/Skeleton3D/IdiscBack
@onready var disc_left = $sapientblockman/Armature/Skeleton3D/IdiscLeft
@onready var disc_left_sc = $sapientblockman/Armature/Skeleton3D/IdiscLeft/IdentityDisc
@onready var disc_right = $sapientblockman/Armature/Skeleton3D/IdiscRight
@onready var disc_right_sc = $sapientblockman/Armature/Skeleton3D/IdiscRight/IdentityDisc
@onready var LightWall = preload("res://objects/lightwallseg.tscn")
@onready var SpecialLightWall= preload("res://objects/speciallightwallseg.tscn")
@onready var Destruction = load("res://destruction/destruction.tscn")
@onready var destruction_instance = Destruction.instantiate()

 
func _ready():
	las_pos = get_global_position()
	las_rot = get_global_rotation()
	
	disc_left_sc.disc_owner = self
	disc_right_sc.disc_owner = self


func _physics_process(_delta):
	pass



func get_last_pos():
	return las_pos
func get_last_rot():
	return las_rot
func set_last_pos(pos: Vector3):
	las_pos = pos
func set_last_rot(rot: Vector3):
	las_rot = rot


func spawn_lw():
	var glo_pos = get_global_position()
	var distance = (las_pos).distance_to(glo_pos)
	var mid_point = Vector3(
		(las_pos.x + glo_pos.x) / 2.0,
		(las_pos.y + glo_pos.y) / 2.0,
		(las_pos.z + glo_pos.z) / 2.0,
	)
	var lw_instance
	if lw_special:
		lw_instance = SpecialLightWall.instantiate()
	else:
		lw_instance = LightWall.instantiate()
	var trails = level_instance.get_node("Trails")
	trails.add_child(lw_instance)
	lw_instance.lw_color = lw_color
	lw_instance.Driver = self
	if trails.get_child_count() >= level_instance.max_trails:
		trails.get_child(0).free()
	lw_instance.set_global_position(mid_point)
	lw_instance.set_global_rotation(las_rot)
	var lw_width = lw_instance.LW_BASE_WIDTH
	lw_instance.scale_object_local(Vector3(1, 1, distance/lw_width))


func explode():
	if not explodable:
		return
	print("boom")
	explodable = false
	steering = 0
	engine_force = 0
	$IDunno/TrailEater.translate(Vector3(0, 100, 0))
	# i'm something of an animator myself
	if get_linear_velocity().length() < 3:
		set_linear_velocity(Vector3.ZERO)
		$Explode.play()
		$lightcycle/Frontwheel.hide()
		$FrontRight/OmniLight3D2.hide()
		await get_tree().create_timer(0.1).timeout
		$lightcycle/Body.hide()
		$sapientblockman.hide()
		await get_tree().create_timer(0.1).timeout
		$lightcycle/Rearwheel.hide()
		$BackRight/OmniLight3D.hide()
	else:
		var last_lin_vel = get_linear_velocity()
		set_linear_velocity(Vector3.ZERO)
		$Explode.play()
		get_parent().add_child(destruction_instance)
		destruction_instance.set_global_position(global_position)
		$sapientblockman.hide()
		for child in $lightcycle.get_children():
			child.hide()
		$FrontRight/OmniLight3D2.hide()
		$BackRight/OmniLight3D.hide()
		destruction_instance.cycle_color = cycle_color
		destruction_instance.prepare()
		for child in destruction_instance.get_children():
			child.apply_impulse(Vector3(
					randi_range(-20, 20),
					randi_range(20, 30),
					randi_range(-20, 20)
			) + last_lin_vel * 0.3)
		await get_tree().create_timer(13).timeout
		destruction_instance.queue_free()
	print("boom")


func take_dmg(dmg_value):
	if hp <= 0:
		return
	hp -= float(dmg_value)
	if hp <= 0:
		dead = true
		controllable = false
		explode()


func take_hit(shot_pos, dmg_value):
	take_dmg(dmg_value)
	$Hit.play()


func apply_materials():
	var lc_materials = MaterialsBus.LC_STYLES
	sbm.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	sbm.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	disc_back.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	disc_back.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	disc_left.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	disc_left.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	disc_right.set_surface_override_material(0, lc_materials[driver_color]["body0"])
	disc_right.set_surface_override_material(1, lc_materials[driver_color]["lwbase"])
	$lightcycle/Body.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Body.set_surface_override_material(1, lc_materials[cycle_color]["body1"])
	$lightcycle/Body/Windshield_001.set_surface_override_material(0, lc_materials[cycle_color]["body1"])
	$lightcycle/Rearwheel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Rearwheel.set_surface_override_material(1, lc_materials[cycle_color]["wheelwells"])
	$lightcycle/Frontwheel.set_surface_override_material(0, lc_materials[cycle_color]["body0"])
	$lightcycle/Frontwheel.set_surface_override_material(1, lc_materials[cycle_color]["wheelwells"])


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -1 * event.relative.x * mouse_sens
			pitch_input = -1 * event.relative.y * mouse_sens

func _on_kill_timeout() -> void:
	take_dmg(10000.0)

func _on_despawn_timeout() -> void:
	queue_free()
