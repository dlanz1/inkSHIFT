extends Node2D

@onready var player: Node = $Player
@onready var win_zone: Area2D = $WinZone

var hud_scene = preload("res://scenes/hud.tscn")
var pause_menu_scene = preload("res://scenes/pause_menu.tscn")
var win_screen_scene = preload("res://scenes/win_screen.tscn")

var win_screen: CanvasLayer

func _ready() -> void:
	if is_instance_valid(player):
		player.respawn_started.connect(_on_player_respawn_started)
	
	# Connect WinZone signal
	if win_zone:
		win_zone.body_entered.connect(_on_win_zone_body_entered)
	
	var hud = hud_scene.instantiate()
	$CanvasLayer.add_child(hud)
	$CanvasLayer.move_child(hud, 0)
	
	var pause_menu = pause_menu_scene.instantiate()
	$CanvasLayer.add_child(pause_menu)
	
	# Add win screen (initially hidden)
	win_screen = win_screen_scene.instantiate()
	add_child(win_screen)
	
	var manager := get_tree().get_first_node_in_group("game_manager")
	if manager and manager.has_method("set_hud"):
		manager.set_hud(hud)


func _on_player_respawn_started() -> void:
	_respawn_blobs()
	_reset_charge()


func _respawn_blobs() -> void:
	var blobs := get_tree().get_nodes_in_group("respawnable_blob")
	for blob in blobs:
		if blob.has_method("respawn"):
			blob.respawn()


func _reset_charge() -> void:
	if get_tree():
		var manager := get_tree().get_first_node_in_group("game_manager")
		if manager and manager.has_method("reset_charge"):
			manager.reset_charge()


func _on_win_zone_body_entered(body: Node2D) -> void:
	# Check if the player entered the win zone
	if body == player and win_screen:
		print("Player reached the win zone!")
		win_screen.show_win_screen()
