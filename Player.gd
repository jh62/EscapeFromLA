extends KinematicBody2D

enum State {
	IDLE
}

export(int) var speed = 100
export(int) var speed_boost = 5

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
			# implementar bounce
			pass
