extends Node

onready var Enemy := preload("res://scenes/entities/Enemy.tscn")
onready var Bullet := preload("res://scenes/entities/Bullet.tscn")
onready var Packs = [
	preload("res://scenes/entities/HealthPack.tscn"),
	preload("res://scenes/entities/AmmoPack.tscn"),
	preload("res://scenes/entities/SmgPack.tscn")
]
onready var player = $Map/Player

onready var quit = false

func _ready() -> void:
	player.connect("_on_player_shoot",self,"on_player_shoot")
	$Hud/Control/CenterContainer/TextureProgress.max_value = 50
	$Hud/Control/CenterContainer/TextureProgress.step = 25

	for c in $Map.get_children():
		if c is Position2D:
			if .85 > randf():
				var e := Enemy.instance()
				e.global_position = c.global_position
				e.connect("_on_enemy_die",self,"on_enemy_die")
				$Map.add_child(e)
				c.queue_free()

func _process(delta: float) -> void:
	$Hud/Control/Label.text = str(player.bullets)
	$Hud/Control/CenterContainer/TextureProgress.value = player.health

func _physics_process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("action") && event.is_action_pressed("down"):
		$Map/Player/Camera2D.position.y = 100
	elif Input.is_action_pressed("action") && event.is_action_pressed("up"):
		$Map/Player/Camera2D.position.y = -50
	else:
		$Map/Player/Camera2D.position.y = 0

	if Input.is_action_just_pressed("ui_cancel"):
		quit = !quit
		$Hud/CancelContainer.visible = quit
	elif quit && Input.is_action_just_pressed("jump"):
		get_tree().change_scene("res://scenes/Menu.tscn")


func _on_Area2D_body_entered(body: Node) -> void:
	var next_scene = load("res://scenes/StageB_Intro.tscn")
	$Area2D.queue_free()
	$Canvas/TextureRect.visible = true
	$Tween.interpolate_property($Canvas/TextureRect,"modulate",Color(0,0,0,0),Color(0,0,0,1),5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	get_tree().change_scene_to(next_scene)

func on_enemy_die(pos) -> void:
	$Tween.interpolate_property($Canvas/Flash,"visible",false,true,.14,Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween,"tween_completed")
	$Canvas/Flash.visible = false
	randomize()

	if .25 > randf():
		var h = Packs[randi()%Packs.size()].instance()
		h.global_position = pos
		h.vel.y -= 300
		$Map.add_child(h)

func on_bullet_hit(from : Node2D, target : Node2D) -> void:
	if from.is_in_group("player") && target.is_in_group("enemy") || from.is_in_group("enemy") && target.is_in_group("player"):
		target.call("on_hit",from, target)

func _on_body_shoot(attacker, pos,dir) -> void:
	var b : KinematicBody2D = Bullet.instance()
	b.global_position = pos
	b.spawner = attacker
	b.dir = dir
	b.connect("_on_bullet_hit",self,"on_bullet_hit")
	$Map.add_child(b)

func _on_Player__on_death() -> void:
	$Tween.interpolate_property($Canvas/Label,"visible_characters",0,11,2,Tween.TRANS_LINEAR)
	$Tween.start()
	$AudioStreamPlayer.stream = load("res://assets/snd/snaake.wav")
	$AudioStreamPlayer.play()
	yield($AudioStreamPlayer,"finished")
	get_tree().reload_current_scene()
