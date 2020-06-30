extends KinematicBody2D

signal _on_shoot(bullet_pos, bullet_dir)

enum State {
	IDLE
}

const bullet_offset := Vector2(32,32)

export(int) var speed = 100
export(float) var speed_boost = 5.0
export(float) var bounce = 50.0

var dir := Vector2.ZERO
var vel := Vector2.ZERO
var state = State.IDLE
var boost = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
#	dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	boost = Input.is_action_pressed("jump")

	if dir.y > 0:
		$AnimationPlayer.play("move_down")
	elif dir.y < 0:
		$AnimationPlayer.play("move_up")
	else:
		$AnimationPlayer.play("idle")

func _physics_process(delta: float) -> void:
	vel += speed * max(1.0,speed_boost * int(boost)) * dir * delta
	vel = move_and_slide(vel)

	if get_slide_count() > 0:
		var collision := get_slide_collision(0)
		if collision.collider.is_in_group("bounds"):
			vel.y = collision.normal.y * bounce

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("shoot"):
			emit_signal("_on_shoot", $BulletPos.global_position, event.position)
