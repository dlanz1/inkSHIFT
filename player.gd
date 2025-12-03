extends CharacterBody2D

signal respawn_started
signal respawn_finished

const SPEED = 160.0
const JUMP_VELOCITY = -255.0

@onready var sprite = $AnimatedSprite2D
@export var respawn_animation: AnimatedSprite2D
@export_node_path("Area2D") var ink_spill_path: NodePath

@onready var ink_spill: Area2D = get_node_or_null(ink_spill_path) as Area2D
@onready var game_manager = %GameManager

const GHOST_SCENE = preload("res://scenes/ghost.tscn")

var spawn_position: Vector2
var position_history: Array[Vector2] = []
const MAX_HISTORY_SIZE := 180 # 3 seconds at 60 FPS

func _ready() -> void:
	# set the initial spawn position to where the player is first placed in the level
	spawn_position = global_position
	if game_manager:
		game_manager.shift_activated.connect(_on_shift_activated)

func _physics_process(delta: float) -> void:
	# Track position
	position_history.append(global_position)
	if position_history.size() > MAX_HISTORY_SIZE:
		position_history.pop_front()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Sprite direction changing based on direction left/right
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
	
	# Play animations
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	move_and_slide()

func respawn() -> void:
	print("Player respawning! Playing animation...")
	respawn_started.emit()
	if respawn_animation:
		var screen_size = get_viewport_rect().size
		var texture_size = respawn_animation.sprite_frames.get_frame_texture("RespawnAnimation", 0).get_size()
		respawn_animation.scale = screen_size / texture_size
		respawn_animation.global_position = screen_size / 2.0
		respawn_animation.visible = true
		respawn_animation.play("RespawnAnimation")

func _on_respawn_animation_finished() -> void:
	print("Animation finished.")
	if respawn_animation:
		respawn_animation.visible = false
	respawn_finished.emit()

func _on_kill_zone_body_entered(_body: Node2D) -> void:
	respawn()

func _on_respawn_animation_frame_changed() -> void:
	var teleport_frame = 18

	if respawn_animation.frame == teleport_frame:
		print("Teleport frame " + str(teleport_frame) + " reached. Moving player.")
		global_position = spawn_position
		velocity = Vector2.ZERO
		# Ensure the ink spill resets once the player teleports back in.
		if ink_spill and ink_spill.has_method("reset_spill"):
			ink_spill.reset_spill()
		self.show()

func _on_shift_activated() -> void:
	if position_history.size() > 0:
		print("Shifting back! History size: ", position_history.size())
		
		var start_pos = global_position
		var end_pos = position_history[0]
		var distance = start_pos.distance_to(end_pos)
		var ghost_count = int(distance / 50.0) # Spawn a ghost every 50 pixels
		
		# Spawn ghosts linearly between start and end
		for i in range(ghost_count + 1):
			var t = float(i) / float(ghost_count + 1) if ghost_count > 0 else 0.0
			var ghost_pos = start_pos.lerp(end_pos, t)
			
			var ghost = GHOST_SCENE.instantiate()
			get_parent().add_child(ghost)
			ghost.global_position = ghost_pos
			
			# Set texture and flip based on current sprite state
			# Note: This uses the current sprite frame for all ghosts. 
			# If we wanted to be fancy we could use history frames, but requirement is "ghosting animation"
			# and "not displaying all previously stored locations".
			# Using current frame is simple and effective for a "dash" effect.
			ghost.set_texture_frame(sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame), sprite.flip_h)

		# Teleport to the oldest position in history (3 seconds ago)
		global_position = position_history[0]
		velocity = Vector2.ZERO
		# Clear history to prevent immediate re-shifting to old positions if ability was spammable (it's not, but good practice)
		# Actually, for a rewind feel, maybe we keep it? But the requirement is "return to location 3 seconds ago".
		# If we don't clear, and we shift again instantly (if possible), we'd go back another 3 seconds?
		# But we need charge to shift, so we can't spam.
		# Let's clear it to be safe and start fresh tracking from the new (old) spot.
		position_history.clear()
	else:
		print("No history to shift to!")
