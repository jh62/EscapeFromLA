extends Area2D

export(float) var speed = 1000

var dir : Vector2
var target_pos : Vector2
var is_exploding = false

func _ready() -> void:
	$AudioStreamPlayer.play()

func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_pos, speed * delta)

	if global_position.distance_to(target_pos) < 1:
		splash()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()

func _on_BulletRound_body_entered(body: Node) -> void:
	explode()

func splash() -> void:
	explode("splash")

func explode(anim_name = "explode") -> void:
	if is_exploding:
		return
	is_exploding = true
	$Sprite.visible = false
	$AnimatedSprite.visible = true
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play(anim_name)
	yield($AnimatedSprite,"animation_finished")
	queue_free()
