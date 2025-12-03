extends Sprite2D

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func set_texture_frame(tex: Texture2D, flip: bool) -> void:
	texture = tex
	flip_h = flip
