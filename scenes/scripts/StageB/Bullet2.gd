extends Area2D

export(float) var speed = 1000

var type = Global.BulletType.PLAYER
var dir : Vector2
var target_pos : Vector2
var is_exploding = false

func _ready() -> void:
	add_to_group("bullets")
	$AudioStreamPlayer.play()

func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_pos, speed * delta)

	if global_position.distance_to(target_pos) < 1:
		splash()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()

func _on_BulletRound_body_entered(body: Node) -> void:
	if body.is_in_group("bounds"):
		#bug, despues lo veo :d
		queue_free()
	if body.is_in_group("bullets"):
		return
	if body.is_in_group("player"):
		if type != Global.BulletType.PLAYER:
			body.on_hit(self)
		else:
			return
	if body.is_in_group("enemies"):
		if type != Global.BulletType.ENEMY:
			body.on_hit(self)
			print("enemy")
		else:
			return

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
	if $AudioStreamPlayer.playing:
		visible = false
		yield($AudioStreamPlayer,"finished")
	queue_free()
