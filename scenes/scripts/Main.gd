extends Node

onready var Enemy := preload("res://scenes/entities/Enemy.tscn")
onready var player = $Map/Player

func _ready() -> void:
	player.connect("_on_player_shoot",self,"on_player_shoot")

	for c in $Map.get_children():
		if c is Position2D:
			if .85 > randf():
				var e := Enemy.instance()
				e.global_position = c.global_position
				e.connect("_on_enemy_die",self,"on_enemy_die")
				$Map.add_child(e)
				c.queue_free()

func _process(delta: float) -> void:
	if $TextureRect.visible:
		$TextureRect.set_global_position(player.global_position - $TextureRect.rect_size / 2)

func _physics_process(delta: float) -> void:
	pass

func _on_Area2D_body_entered(body: Node) -> void:
	$Area2D.queue_free()
	$Tween.interpolate_property($TextureRect,"modulate",Color(0,0,0,0),Color(0,0,0,1),5,Tween.TRANS_LINEAR,Tween.EASE_OUT,0)
	$Tween.start()
	$TextureRect.visible = true
	yield($Tween,"tween_all_completed")
	print("change scene")

func on_enemy_die() -> void:
	$Tween.interpolate_property($Canvas/Flash,"visible",false,true,.1,Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween,"tween_completed")
	$Canvas/Flash.visible = false
