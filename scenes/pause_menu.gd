extends Control

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume_game()
		else:
			_pause_game()

func _pause_game() -> void:
	show()
	get_tree().paused = true

func _resume_game() -> void:
	hide()
	get_tree().paused = false

func _on_yes_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _on_no_pressed() -> void:
	_resume_game()
