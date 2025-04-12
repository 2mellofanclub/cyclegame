extends Node3D


const LW_BASE_WIDTH := 0.5
var hot := false
var using_shader := true
var Driver : VehicleBody3D
var lc_styles = MaterialsBus.LC_STYLES
var lw_color := "godwhite"


func _ready():
	hide()


# change how and when materials are received, i.e. from mbus upon instantiation
func _process(delta):
	if Driver == null:
		return
	$Shell/DaGoodBox.cpoint = Driver.get_node("IDunno/TrailEater").get_global_position()
	$Shell/DaGoodBox.dcpoint = Driver.get_node("IDunno/TrailDestroyer").get_global_position()
	#var edge_to_bike = (LW_BASE_WIDTH * 0.5 * scale.z) + 1.6
	if not visible:
		if global_position.distance_to(Driver.get_global_position()) > 1.5:
			$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["slwbase"])
			show()
	elif not hot:
		if global_position.distance_to(Driver.get_global_position()) > 2.0:
			hot = true
	elif using_shader:
		if global_position.distance_to(Driver.get_global_position()) > 2.0:
			using_shader = false
			$Shell/DaGoodBox.using_shader = false
			$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["lwbase"])


func _on_lightarea_body_entered(body):
	if not hot:
		return
	if "take_dmg" in body:
			print("ka")
			body.take_dmg(10000.0)


func _on_timer_timeout() -> void:
	queue_free()


func _on_lightosci_timeout() -> void:
	if using_shader:
		$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["slwpulse"])
		await get_tree().create_timer(0.1).timeout
		$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["slwbase"])
	else:
		$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["lwpulse"])
		await get_tree().create_timer(0.1).timeout
		$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["lwbase"])
