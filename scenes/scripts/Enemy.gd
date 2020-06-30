extends KinematicBody2D

signal _on_enemy_die()

export(int) var health := 100
export(float) var speed := 20

onready var state = STATES.IDLE
onready var knows := 0.0

var dir = Vector2(randi()%1-1,0)
var velocity : Vector2 = Vector2.ZERO

enum STATES {
	IDLE,
	MOVING,
	RUNNING,
	JUMPING,
	SHOOTING,
	ALERT,
	DIYING,
	HURT
}

class_name Enemy

func _ready() -> void:
	#randomize es para que cambie la seed de randi, sino siempre usa la misma
	randomize()
	$TimerThink.start(3)
	$BloodFX.emitting = false
	state = STATES.MOVING
	add_to_group("enemy")

var new_dir = Vector2.ZERO

func _process(delta: float) -> void:
	if state == STATES.HURT:
		if !$AnimationPlayer.is_playing():
			state = STATES.MOVING
	if state == STATES.DIYING:
		set_physics_process(false)
		$CollisionShape2D.disabled = true
		if !$AnimationPlayer.is_playing():
			set_process(false)
			for c in get_children():
				if !(c is Sprite):
					remove_child(c)
					c.queue_free()
			return
		return
	if state == STATES.MOVING:
		if $RaycastRoot/RayCastBehind.is_colliding():
			dir = global_position.direction_to($RaycastRoot/RayCastBehind.get_collider().global_position)
			$AudioStreamPlayer.stream = Global.getSound("knows")
			$AudioStreamPlayer.play()
			$SpriteKnows.visible = true
			$TimerKnowsFade.start(.5)
		if $ShootRay.is_colliding():
			state = STATES.SHOOTING
			knows = 1.0
			return
		if !$RaycastRoot/RayCastLeft.is_colliding():
			dir.x = 1
		elif !$RaycastRoot/RayCastRight.is_colliding():
			dir.x = -1

		if dir.x < 0:
			$AnimationPlayer.play("run_w")
		else:
			$AnimationPlayer.play("run_e")
		velocity = speed * dir

		if knows > .001:
			knows *= .97
			velocity.x *= 5
		else:
			knows = 0.0
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

	if get_slide_count() > 0:
		var collider = get_slide_collision(0).collider

		if collider.is_in_group("enemy"):
			dir *= -1
		elif collider.is_in_group("item"):
			dir *= -1

func _on_TimerThink_timeout() -> void:
	if knows > .9:
		return
	if .85 > randf():
		dir = Vector2(-dir.x,0)
		$TimerThink.wait_time = randi()%3+8

	if dir.x == -1 && $RaycastRoot/RayCastLeft.is_colliding():
		dir = Vector2(-1,0)
	elif dir.x == 1 && $RaycastRoot/RayCastRight.is_colliding():
		dir = Vector2(1,0)

func on_hit(attacker,target) -> void:
	if target != self:
		return

	health -= attacker.damage
	$BloodFX.one_shot = true
	$BloodFX.visible = true
	$BloodFX.emitting = true
	if health <= 0:
		emit_signal("_on_enemy_die")
		$AudioStreamPlayer.stream = Global.getSound("die")
		$AudioStreamPlayer.pitch_scale = rand_range(.92,1)
		$AudioStreamPlayer.play()
		state = STATES.DIYING
		velocity = Vector2.ZERO
		if dir.x < 0:
			$AnimationPlayer.play("die_w")
		else:
			$AnimationPlayer.play("die_e")
		return
	else:
		$AudioStreamPlayer.stream = Global.getSound("hurt")
		$AudioStreamPlayer.pitch_scale = 1.0
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("hurt_1_e" if dir.x > 0 else "hurt_1_w")
		state = STATES.HURT


func _on_TimerKnowsFade_timeout() -> void:
	$SpriteKnows.visible = false
