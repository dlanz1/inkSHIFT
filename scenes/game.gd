extends Node2D

@onready var player: Node = $Player

var hud_scene = preload("res://scenes/hud.tscn")
var pause_menu_scene = preload("res://scenes/pause_menu.tscn")

func _ready() -> void:
	if is_instance_valid(player):
		player.respawn_started.connect(_on_player_respawn_started)
	
	var hud = hud_scene.instantiate()
	$CanvasLayer.add_child(hud)
	$CanvasLayer.move_child(hud, 0)
	
	var pause_menu = pause_menu_scene.instantiate()
	$CanvasLayer.add_child(pause_menu)
	
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
