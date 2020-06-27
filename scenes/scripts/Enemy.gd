extends KinematicBody2D

var dir = Vector2(randi()%1-1,0)

export(int) var health := 100
export(float) var speed := 20

class_name Enemy

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if $RaycastRoot/RayCastLeft.is_colliding() && dir.x == -1 || $RaycastRoot/RayCastRight.is_colliding() && dir.x == 1:
		move_and_slide(dir * speed)

func _on_TimerThink_timeout() -> void:
	if .85 > randf():
		dir = Vector2(-dir.x,0)
		$TimerThink.wait_time = randi()%3+8

	if dir.x == -1 && $RaycastRoot/RayCastLeft.is_colliding():
		dir = Vector2(-1,0)
	elif dir.x == 1 && $RaycastRoot/RayCastRight.is_colliding():
		dir = Vector2(1,0)

func on_hit(attacker) -> void:
	print("ouch!")
