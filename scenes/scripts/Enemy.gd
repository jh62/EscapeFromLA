extends KinematicBody2D

signal _on_enemy_die(pos)
signal _on_shoot(this, pos,dir)

export(int) var health := 100
export(float) var speed := 20
export(float) var damage := 5

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
	connect("_on_shoot",get_tree().current_scene,"_on_body_shoot")
	randomize()
	$TimerThink.start(randi()%2+1)
	$BloodFX.emitting = false
	state = STATES.MOVING
	add_to_group("enemy")

var new_dir = Vector2.ZERO

func _process(delta: float) -> void:
	if state == STATES.HURT:
		if !$AnimationPlayer.is_playing():
			state = STATES.MOVING
		return
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
		if $RaycastRoot/RayCastBehind.is_colliding() && $TimerKnowsFade.is_stopped():
			$AudioStreamPlayer.stream = Global.getSound("knows")
			$AudioStreamPlayer.play()
			$TimerKnowsFade.start(.5)
			$SpriteKnows.visible = true
		if $ShootRay.is_colliding():
			state = STATES.SHOOTING
			knows = 1.0
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
		if !$TimerShoot.is_stopped():
			return
		elif !$ShootRay.is_colliding():
			state = STATES.MOVING
			return

		velocity = Vector2.ZERO
		$AnimationPlayer.play("idle_w" if dir.x < 0 else "idle_e")
		$TimerShoot.start()

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
	if !$TimerKnowsFade.is_stopped() || !$TimerShoot.is_stopped():
		return
	if knows > .9:
		return
	if .85 > randf():
		dir.x *= -1
		randomize()
		$TimerThink.wait_time = randi()%2+1
	if dir.x == -1 && $RaycastRoot/RayCastLeft.is_colliding():
		dir = Vector2(-1,0)
	elif dir.x == 1 && $RaycastRoot/RayCastRight.is_colliding():
		dir = Vector2(1,0)

func on_hit(attacker,target) -> void:
	if target != self:
		return

	health -= attacker.damage
	$TimerShoot.stop()
	$BloodFX.one_shot = true
	$BloodFX.visible = true
	$BloodFX.emitting = true
	if health <= 0:
		emit_signal("_on_enemy_die",self.global_position)
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
	dir *= -1

func _on_TimerShoot_timeout() -> void:
	if state != STATES.SHOOTING:
		return
#	elif !$ShootRay.is_colliding():
#		state = STATES.MOVING
#		return

	emit_signal("_on_shoot",self, $BulletPos.global_position, dir)
	$AnimationPlayer.current_animation = "shoot_w" if dir.x < 0 else "shoot_e"
	$AudioStreamPlayer.stream = Global.getSound("shoot")
	$AudioStreamPlayer.play()
