extends Node2D

onready var Crosshair = preload("res://assets/stageB/crosshair.png")
onready var Bullet = preload("res://scenes/entities/StageB/Bullet2.tscn")

func _ready() -> void:
	$Map/Top.add_to_group("bounds")
	$Map/Bottom.add_to_group("bounds")
	Input.set_custom_mouse_cursor(Crosshair, 0, Vector2(16,18))

func _on_Player__on_shoot(pos : Vector2, dir : Vector2) -> void:
	var b = Bullet.instance()
	b.global_position = pos
	b.target_pos = dir
	$Map.add_child(b)
