extends KinematicBody2D

signal _on_bullet_hit(shooter,shooted)

enum State {
	FLYING,
	EXPLODING
}

export(float) var speed = 100
export(Vector2) var initial_speed = Vector2(1200,0)

onready var state = State.FLYING
onready var vel : Vector2 = initial_speed

var dir : Vector2
var spawner : Node

func _ready() -> void:
	vel = initial_speed * dir

func _physics_process(delta: float) -> void:
	match state:
		State.FLYING:
			vel += dir * speed * delta
#			vel.x += (initial_speed + speed * delta) * dir.x
			vel = move_and_slide(vel)
			if get_slide_count() > 0:
				var collider = get_slide_collision(0).collider
				emit_signal("_on_bullet_hit",spawner, collider)
				explode()
		State.EXPLODING:
			yield($AnimSpriteExplode,"animation_finished")
			call_deferred("queue_free")

func explode():
	$SpriteBullet.visible = false
	$AnimSpriteExplode.visible = true
	$AnimSpriteExplode.frame = 0
	$AnimSpriteExplode.play("explode")
	state = State.EXPLODING

func _on_VisibilityNotifier2D_screen_exited() -> void:
	$CollisionShape2D.disabled = true
	explode()
