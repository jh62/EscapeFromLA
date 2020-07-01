extends Node2D

onready var Crosshair = preload("res://assets/stageB/crosshair.png")
onready var Bullet = preload("res://scenes/entities/StageB/Bullet2.tscn")
onready var Grenade = preload("res://scenes/entities/Grenade.tscn")

func _ready() -> void:
	$Map/Top.add_to_group("bounds")
	$Map/Bottom.add_to_group("bounds")
	Input.set_custom_mouse_cursor(Crosshair, 0, Vector2(16,18))

func _on_Player__on_shoot(pos : Vector2) -> void:
	var b = Bullet.instance()
	b.global_position = pos
	b.target_pos = get_global_mouse_position()
	$Map.add_child(b)


func _on_Player__on_grenade_throw(throw_pos) -> void:
	var g = Grenade.instance()
	g.global_position = throw_pos
	g.target_pos = get_global_mouse_position()
	$Map.add_child(g)
