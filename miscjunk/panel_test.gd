extends Control




func _on_panel_container_gui_input(event: InputEvent) -> void:
	print("PanelContainer: " + event.as_text())


func _on_panel_gui_input(event: InputEvent) -> void:
	print("Panel: " + event.as_text())


func _on_panel_container_mouse_entered() -> void:
	print("PanelContainer entered")


func _on_panel_container_mouse_exited() -> void:
	print("PanelContainer exited")


func _on_panel_mouse_entered() -> void:
	print("Panel entered")


func _on_panel_mouse_exited() -> void:
	print("Panel exited")
