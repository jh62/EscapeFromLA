extends "res://scenes/entities/HealthPack.gd"


func _ready() -> void:
	$AnimationPlayer.play("idle_smg")

func on_pickedup(body) -> void:
	body.bullets = 30
	body.max_bullets = 30
	body.damage = 15
	body.shoot_sound = load("res://assets/snd/smg.wav")
	body.shoot_delay = .12
	body.knockback = Vector2(12,0)
