extends KinematicBody2D

signal _on_shoot(bullet_pos)
signal _on_grenade_throw(throw_pos)
signal _on_player_death()

enum State {
	MOVING,
	DYING,
	DEAD
}

const bullet_offset := Vector2(32,32)

onready var snd_reload = preload("res://assets/snd/rld.wav")
onready var snd_dry = preload("res://assets/snd/dry.wav")
onready var snd_scream = preload("res://assets/snd/scream.wav")

export(int) var health = 100
export(int) var speed = 100
export(float) var speed_boost = 19.0
export(float) var bounce = 50.0
export(int) var max_bullets = 20
export(float) var reload_time = 1.15

var dir := Vector2.ZERO
var vel := Vector2.ZERO
var boost := 0
var state = State.MOVING
var bullets = max_bullets

func _ready() -> void:
	add_to_group("player")

func _process(delta: float) -> void:
	match state:
		State.MOVING:
			dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")

			if dir.y > 0:
				$AnimationPlayer.play("move_down")
			elif dir.y < 0:
				$AnimationPlayer.play("move_up")
			else:
				$AnimationPlayer.play("idle")

func _physics_process(delta: float) -> void:
	match state:
		State.MOVING:
			vel += speed * dir * delta
			vel.y += boost
			vel = move_and_slide(vel)

			if boost != 0:
				boost = lerp(boost,0,.01)
			else:
				boost = 0

			if get_slide_count() > 0:
				var collision := get_slide_collision(0)
				if collision.collider.is_in_group("bounds"):
					vel.y = collision.normal.y * bounce

func _unhandled_input(event: InputEvent) -> void:
	match state:
		State.MOVING:
			if event.is_action_pressed("shoot") && $TimerReload.is_stopped():
				if bullets > 0:
					emit_signal("_on_shoot", $BulletPos.global_position)
					bullets -= 1
					if bullets < 0:
						bullets = 0
				else:
					$AudioGun.stream = snd_dry
					$AudioGun.play()
			elif event.is_action_pressed("secondary") && $TimerGrenade.is_stopped():
				$TimerGrenade.start()
				emit_signal("_on_grenade_throw", global_position)
			elif event.is_action_pressed("reload"):
				if bullets < max_bullets && $TimerReload.is_stopped():
					$AudioGun.stream = snd_reload
					$AudioGun.play()
					$TimerReload.one_shot = true
					$TimerReload.start(reload_time)
			elif event.is_action_pressed("jump"):
				if $TimerBoost.is_stopped():
					$AudioStreamPlayer.play()
					$TimerBoost.start(1.0)
					boost = speed_boost * dir.y

func _on_TimerReload_timeout() -> void:
	bullets = max_bullets

func on_hit(attacker) -> void:
	if boost > 0:
		return
	if state != State.MOVING:
		return

	health -= 10
	if health <= 0:
		state = State.DYING
		$AnimationPlayer.play("die")
		$AudioStreamPlayer.stream = snd_scream
		$AudioStreamPlayer.play()
		yield($AnimationPlayer,"animation_finished")
		if $AudioStreamPlayer.playing:
			yield($AudioStreamPlayer,"finished")
		state = State.DEAD
		emit_signal("_on_player_death")
