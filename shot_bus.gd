extends Node

const SHOT_TYPES = {
	"machinegun1" : {
		"rof" : 10.0,
		"dmg" : 200.0,
		"muzzle_force" : 200.0,
		"scale" : Vector3(1.0, 1.0, 1.0),
		"ddot_rad" : 0.5,
		"bullet_count" : 1,
		"bullet_mass" : 0.4,
		"spread" : 0.0,
	},
	"cannon1" : {
		"rof" : 0.5,
		"dmg" : 4000.0,
		"muzzle_force" : 200.0,
		"scale" : Vector3(1.8, 1.8, 1.8),
		"ddot_rad" : 1.5,
		"bullet_count" : 1,
		"bullet_mass" : 2.0,
		"spread" : 0.0,
	},
	"shotgun1" : {
		"rof" : 0.5,
		"dmg" : 200.0,
		"muzzle_force" : 50.0,
		"scale" : Vector3(0.5, 0.5, 0.5),
		"ddot_rad" : 0.25,
		"bullet_count" : 25,
		"bullet_mass" : 0.2,
		"spread" : 1.0,
	},
	
}
