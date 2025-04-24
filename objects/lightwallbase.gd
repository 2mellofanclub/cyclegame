extends Node3D


const LW_BASE_WIDTH := 0.5
var Driver : VehicleBody3D
var lc_styles = MaterialsBus.LC_STYLES
var lw_color := "godwhite"


func _ready():
	hide()


# change how and when materials are received, i.e. from mbus upon instantiation
func _process(delta):
	if Driver == null:
		return
	$Shell/DaGoodBox.cpoint = Driver.get_node("IDunno/TrailEater").global_position
	$Shell/DaGoodBox.dcpoint = Driver.get_node("IDunno/TrailDestroyer").global_rotation
	#var edge_to_bike = (LW_BASE_WIDTH * 0.5 * scale.z) + 1.6


func _on_lightosci_timeout() -> void:
	$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["slwpulse"])
	await get_tree().create_timer(0.1).timeout
	$Shell/DaGoodBox.set_surface_override_material(0, lc_styles[lw_color]["slwbase"])
	
