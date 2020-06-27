extends KinematicBody2D

var dir = Vector2(randi()%1-1,0)

var velocity : Vector2 = Vector2.ZERO

export(int) var health := 100
export(float) var speed := 20

onready var state = STATES.IDLE

enum STATES {
	IDLE,
	MOVING,
	RUNNING,
	JUMPING,
	SHOOTING,
	DIYING
}

class_name Enemy

func _ready() -> void:
	#randomize es para que cambie la seed de randi, sino siempre usa la misma
	randomize()
	state = STATES.MOVING
	pass

func _process(delta: float) -> void:
	if state == STATES.DIYING:
		if !$AnimationPlayer.is_playing():
			queue_free()
		return
	if state == STATES.MOVING:
		if $ShootRay.is_colliding():
			state = STATES.SHOOTING
			return
		if !$RaycastRoot/RayCastLeft.is_colliding():
			dir.x = 1
		elif !$RaycastRoot/RayCastRight.is_colliding():
			dir.x = -1
		if dir.x < 0:
			$AnimationPlayer.play("run_w")
		else:
			$AnimationPlayer.play("run_e")
		velocity = speed*dir
	if state == STATES.SHOOTING:
		velocity.x = 0
		if dir.x < 0:
			$AnimationPlayer.current_animation = ("shoot_w")
		else:
			$AnimationPlayer.current_animation = ("shoot_e")
		if !$ShootRay.is_colliding():
			state = STATES.MOVING

func _physics_process(delta: float) -> void:
	# misma aclaracion que en player
	velocity += Global.GRAVITY*delta
	velocity = move_and_slide(velocity)

func _on_TimerThink_timeout() -> void:
	if .85 > randf():
		dir = Vector2(-dir.x,0)
		$TimerThink.wait_time = randi()%3+8

	if dir.x == -1 && $RaycastRoot/RayCastLeft.is_colliding():
		dir = Vector2(-1,0)
	elif dir.x == 1 && $RaycastRoot/RayCastRight.is_colliding():
		dir = Vector2(1,0)

func on_hit(attacker) -> void:
	health -= attacker.damage
	if health <= 0:
		state = STATES.DIYING
		velocity = Vector2.ZERO
		if dir.x < 0:
			$AnimationPlayer.play("die_w")
		else:
			$AnimationPlayer.play("die_e")
	print("ouch!")
