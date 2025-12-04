extends Control

@onready var start_button: Button = $start
@onready var exit_button: Button = $exit
@onready var difficulty_selector: VBoxContainer = $DifficultySelector

func _ready() -> void:
	difficulty_selector.visible = false

func _on_start_pressed() -> void:
	start_button.visible = false
	exit_button.visible = false
	difficulty_selector.visible = true

func _on_pencil_pressed() -> void:
	GameManager.difficulty_modifier = 40.0
	_start_game()

func _on_pen_pressed() -> void:
	GameManager.difficulty_modifier = 20.0
	_start_game()

func _on_sharpie_pressed() -> void:
	GameManager.difficulty_modifier = 0.0
	_start_game()

func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
