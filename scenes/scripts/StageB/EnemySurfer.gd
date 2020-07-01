extends KinematicBody2D

signal _on_shoot(bullet_pos)
signal _on_enemy_die()

enum State {
	SPAWN,
	MOVING,
	DYING
}

const bullet_offset := Vector2(32,32)

onready var r_Alert = preload("res://assets/snd/alert.wav")

export(int) var health = 100
export(int) var speed = 100
export(float) var bounce = 50.0

var dir := Vector2.ZERO
var vel := Vector2.ZERO
var random_pos
var stop_force := 5.0

onready var state = State.SPAWN
onready var target : KinematicBody2D= get_tree().current_scene.find_node("Player")

func _ready() -> void:
	randomize()
	stop_force = rand_range(.2,0.97)
	add_to_group("enemies")
	connect("_on_shoot",get_tree().current_scene,"on_enemy_shoot")
	connect("_on_enemy_die",get_tree().current_scene,"on_enemy_die")

func _process(delta: float) -> void:
	match state:
		State.SPAWN:
			pass
		State.MOVING:
			if dir.y > 0:
				$AnimationPlayer.play("move_down")
			elif dir.y < 0:
				$AnimationPlayer.play("move_up")
			else:
				$AnimationPlayer.play("idle")

			if $TimerThink.time_left > 1 && $TimerThink.time_left < 1.5:
				$SpriteKnows.visible = true
#				if !$AudioStreamPlayer.playing:
#					$AudioStreamPlayer.stream = r_Alert
#					$AudioStreamPlayer.pitch_scale = rand_range(.9,1.1)
#					$AudioStreamPlayer.play()
			else:
				$SpriteKnows.visible = false
		State.DYING:
			pass
func _physics_process(delta: float) -> void:
	match state:
		State.SPAWN:
			if global_position.x > 580:
				vel += speed * delta * Vector2(-1,0)
				vel = move_and_slide(vel)
			else:
				$TimerShoot.wait_time = rand_range(1.25,2)
				$TimerShoot.start()
				state = State.MOVING
		State.MOVING:
			vel += speed * delta * dir
			vel = move_and_slide(vel)

			if vel.x < -1.0:
				vel.x = lerp(vel.x, 0.0, stop_force * delta)
			else:
				vel.x = 0

			if get_slide_count() > 0:
				var collision := get_slide_collision(0)
				if collision.collider.is_in_group("bounds"):
					vel.y = collision.normal.y * bounce
		State.DYING:
			pass

func  on_hit(attacker : Node2D) -> void:
	if attacker.is_in_group("bullets"):
		health -= 50
	elif attacker.is_in_group("grenades"):
		health -= 100

	if health <= 0:
		state = State.DYING
		emit_signal("_on_enemy_die")
		$AudioStreamPlayer.stream = Global.getSound("die")
		$AudioStreamPlayer.pitch_scale = rand_range(.9,1.0)
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("die")
		yield($AnimationPlayer,"animation_finished")
		visible = false
		if $AudioStreamPlayer.playing:
			yield($AudioStreamPlayer,"finished")
		queue_free()

func _on_TimerThink_timeout() -> void:
	if target != null:
		dir = global_position.direction_to(target.global_position)
		dir.x = 0

func _on_TimerShoot_timeout() -> void:
	if state == State.MOVING:
		emit_signal("_on_shoot", $BulletOffset.global_position)
	if global_position.y > 300 || global_position.y < 30:
		#bug, despues lo veo :d
		queue_free()
