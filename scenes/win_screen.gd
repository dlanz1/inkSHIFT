extends CanvasLayer

signal play_again_pressed
signal main_menu_pressed

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var message_label: Label = $Panel/VBoxContainer/MessageLabel
@onready var play_again_button: Button = $Panel/VBoxContainer/ButtonContainer/PlayAgainButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/ButtonContainer/MainMenuButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var win_sound: AudioStreamPlayer = $WinSound

var _tween: Tween


func _ready() -> void:
	# Start hidden
	visible = false
	panel.modulate.a = 0.0


func show_win_screen() -> void:
	visible = true
	get_tree().paused = true
	
	# Play win sound
	if win_sound:
		win_sound.play()
	
	# Animate the panel appearing with ink splatter effect
	_animate_entrance()


func _animate_entrance() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	
	# Scale from small to full size with bounce
	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2(0.3, 0.3)
	panel.modulate.a = 0.0
	
	_tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.6)
	_tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.3)
	
	# Add a subtle shake effect after appearing
	_tween.tween_callback(_add_shake_effect)


func _add_shake_effect() -> void:
	var shake_tween = create_tween()
	shake_tween.set_ease(Tween.EASE_IN_OUT)
	shake_tween.set_trans(Tween.TRANS_SINE)
	
	var original_pos = panel.position
	shake_tween.tween_property(panel, "position", original_pos + Vector2(5, 0), 0.05)
	shake_tween.tween_property(panel, "position", original_pos + Vector2(-5, 0), 0.05)
	shake_tween.tween_property(panel, "position", original_pos + Vector2(3, 0), 0.05)
	shake_tween.tween_property(panel, "position", original_pos, 0.05)


func _on_play_again_button_pressed() -> void:
	get_tree().paused = false
	play_again_pressed.emit()
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	main_menu_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
