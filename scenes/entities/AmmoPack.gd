extends "res://scenes/entities/HealthPack.gd"


func _ready() -> void:
	$AnimationPlayer.play("idle_shotgun")

func on_pickedup(body) -> void:
	body.bullets = 2
	body.max_bullets = 2
	body.damage = 100
	body.shoot_sound = load("res://assets/snd/shotgun1.wav")
	body.shoot_delay = .5
	body.knockback = Vector2(98,0)
