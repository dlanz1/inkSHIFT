extends Node
class_name GameManager

const GROUP_NAME := "game_manager"
const MAX_CHARGE := 8

signal shift_activated

var double_jump_charge := 0
static var difficulty_modifier: float = 0.0
var hud: Control

@onready var charge_label: Label = $ChargeLabel


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_update_charge_label()


func set_hud(hud_node: Control) -> void:
	hud = hud_node
	_update_hud()


func add_charge() -> void:
	# Increment the collected charge counter and update HUD.
	if double_jump_charge < MAX_CHARGE:
		double_jump_charge += 1
		print(double_jump_charge)
		_update_charge_label()
		_update_hud()
		
		if double_jump_charge == MAX_CHARGE:
			_set_invert_effect(true)


func reset_charge() -> void:
	# Reset charge count when the player respawns.
	double_jump_charge = 0
	_update_charge_label()
	_update_hud()
	_set_invert_effect(false)


func _update_charge_label() -> void:
	if charge_label:
		charge_label.text = "you collected " + str(double_jump_charge) + " charge"


func _update_hud() -> void:
	if hud:
		var charge_bar = hud.get_node_or_null("ChargeBar")
		if charge_bar:
			charge_bar.value = double_jump_charge
			
			var shift_label = charge_bar.get_node_or_null("ShiftLabel")
			if shift_label:
				shift_label.visible = (double_jump_charge == MAX_CHARGE)


func _set_invert_effect(enabled: bool) -> void:
	if hud:
		var invert_overlay = hud.get_node_or_null("InvertOverlay")
		if invert_overlay:
			invert_overlay.visible = enabled


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift") and double_jump_charge == MAX_CHARGE:
		print("Ability Triggered!")
		shift_activated.emit()
		reset_charge()
