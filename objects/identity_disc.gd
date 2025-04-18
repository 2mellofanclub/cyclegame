extends Node3D

var disc_owner
var disc_color := "blue"
var materials_applied := false
var hitbox_active := false
#var disc_dmg := 0.0
#var explosive := false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func apply_materials():
	var disc_materials = SignalBus.DISC_STYLES
	$Idisc.set_surface_override_material(0, disc_materials["body0"])
	$Idisc.set_surface_override_material(1, disc_materials["trims"])
	materials_applied = true


func _on_hit_box_body_entered(body: Node3D) -> void:
	if hitbox_active and "replace_w_group" in body:
		if body != disc_owner:
			body.explode()
