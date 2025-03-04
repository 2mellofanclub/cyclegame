extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_lightarea_body_entered(body):
	if body.name == "Player":
		if body.is_alive():
			print("ka")
			body.explode()


func _on_timer_timeout() -> void:
	queue_free() # Replace with function body.


func _on_lightosci_timeout() -> void:
	# why is this 0.0 when it's set to 5.0?
	var original_range = $ligths/bottom1.get_param($ligths/bottom1.omni_range)
	#print(original_range)
	$ligths/bottom1.set_param($ligths/bottom1.omni_range, 1.0)
	$ligths/bottom2.set_param($ligths/bottom2.omni_range, 1.0)
	$ligths/upper1.set_param($ligths/upper1.omni_range, 1.0)
	$ligths/upper2.set_param($ligths/upper2.omni_range, 1.0)
	await get_tree().create_timer(0.1).timeout
	$ligths/bottom1.set_param($ligths/bottom1.omni_range, original_range)
	$ligths/bottom2.set_param($ligths/bottom2.omni_range, original_range)
	$ligths/upper1.set_param($ligths/upper1.omni_range, original_range)
	$ligths/upper2.set_param($ligths/upper2.omni_range, original_range)
