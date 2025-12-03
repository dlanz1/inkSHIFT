extends CharacterBody2D

signal respawn_started
signal respawn_finished

const SPEED = 160.0
const JUMP_VELOCITY = -255.0

@onready var sprite = $AnimatedSprite2D
@export var respawn_animation: AnimatedSprite2D
@export_node_path("Area2D") var ink_spill_path: NodePath

@onready var ink_spill: Area2D = get_node_or_null(ink_spill_path) as Area2D

var spawn_position: Vector2

func _ready() -> void:
	# set the initial spawn position to where the player is first placed in the level
	spawn_position = global_position

func _physics_process(delta: float) -> void:
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
