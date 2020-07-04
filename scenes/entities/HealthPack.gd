extends KinematicBody2D

var vel : Vector2
var picked = false
var mass := 546.0

func _ready() -> void:
	$AnimationPlayer.play("idle_health")

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		vel += Global.GRAVITY.normalized() * mass * delta
		move_and_slide(vel,Global.UP_DIRECTION)
	else:
		set_physics_process(false)

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player") && !picked:
		picked = true
		on_pickedup(body)
		set_physics_process(false)
		$CollisionShape2D.disabled = true
		$AudioStreamPlayer.play()
		yield($AudioStreamPlayer,"finished")
		queue_free()

func on_pickedup(body) -> void:
	body.health = 50
