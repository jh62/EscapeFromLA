extends Area2D

class_name Grenade

export(float) var throw_speed := 800.0

onready var p : Path2D = $Path2D
onready var f : PathFollow2D = $Path2D/PathFollow2D
onready var target_pos : Vector2
onready var points : PoolVector2Array
var t = 0
var arc := 100.0
var exploding = false

func _ready() -> void:
	p.curve = Curve2D.new()

	var middle_point : Vector2 = global_position.linear_interpolate(target_pos, .5) + Vector2(0,-arc)

	p.curve.add_point(global_position, Vector2.ZERO, Vector2(0,-arc))
	p.curve.add_point(middle_point)
	p.curve.add_point(target_pos, Vector2(-10,-arc), Vector2.ZERO)
	points = p.curve.get_baked_points()

func _process(delta: float) -> void:
	if f.unit_offset >= 1.0:
		explode()
		return

	$Path2D/PathFollow2D.offset += throw_speed * delta
	global_position = $Path2D/PathFollow2D.position

func explode() -> void:
	if exploding:
		return
	for b in get_overlapping_bodies():
		var body : Node2D = b
		if body.is_in_group("enemies"):
			body.on_hit(self)

	exploding = true
	$Sprite.visible = false
	$AnimatedSprite.visible = true
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("explode")
	$AudioStreamPlayer.play()

func _on_AnimatedSprite_animation_finished() -> void:
	$AnimatedSprite.visible = false

func _on_AudioStreamPlayer_finished() -> void:
	if $AnimatedSprite.is_playing():
		yield($AnimatedSprite,"animation_finished")
	queue_free()
