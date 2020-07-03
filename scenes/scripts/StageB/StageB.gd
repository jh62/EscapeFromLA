extends Node2D

onready var next_scene = preload("res://scenes/EndIntro.tscn")
onready var Crosshair = preload("res://assets/stageB/crosshair.png")
onready var Bullet = preload("res://scenes/entities/StageB/Bullet2.tscn")
onready var Grenade = preload("res://scenes/entities/Grenade.tscn")
onready var Grenade2 = preload("res://scenes/entities/StageB/Grenade2.tscn")
onready var Enemy = preload("res://scenes/entities/StageB/EnemySurfer.tscn")

export(int) var MAX_ENEMY_COUNT = 12

onready var player = find_node("Player")
var enemy_count = 0
var mts_to_finish := 1000
var finished = false

func _ready() -> void:
	$Map/Top.add_to_group("bounds")
	$Map/Bottom.add_to_group("bounds")
	Input.set_custom_mouse_cursor(Crosshair, 0, Vector2(16,18))

	yield(get_tree().create_timer(3),"timeout")
	$Timer.start()

func _process(delta: float) -> void:
	if player.health <= 0:
		return

	$Hud/Control/Label.text = str(player.bullets)
	$Hud/Control/CenterContainer/TextureProgress.value = player.health

	if mts_to_finish <= 0:
		if !finished:
			finished = true
			$Timer.stop()
			$Timer2.stop()
			for e in get_tree().get_nodes_in_group("enemies"):
				e.playDead()
			player.set_process(false)
			player.set_physics_process(false)
			player.state = player.State.IDLE
		else:
			var vel = $Position2D.global_position - player.global_position
			vel = vel.normalized() *  delta * player.speed * .25
			player.global_position += vel

			if player.global_position.distance_to($Position2D.global_position) < 5:
				get_tree().change_scene_to(next_scene)
	else:
		$Hud/LabelMiles.text = "Miles left: " + str(mts_to_finish)

func _on_Player__on_shoot(pos : Vector2, is_joy = false) -> void:
	var shoot_dir = get_global_mouse_position()
	if is_joy:
		shoot_dir = Vector2(640,player.global_position.y)
	var bullet = spawnBullet(pos, shoot_dir)
	bullet.type = Global.BulletType.PLAYER

func on_enemy_shoot(pos : Vector2) -> void:
	var bullet = spawnBullet(pos, player.player_center.global_position)
	bullet.type = Global.BulletType.ENEMY

func _on_Player__on_grenade_throw(throw_pos, is_joy = false) -> void:
	var shoot_dir = get_global_mouse_position()
	if is_joy:
		shoot_dir = Vector2(500,player.global_position.y)
	$Hud/Control/AnimHud.play("nate_load")
	var g : Grenade2 = Grenade2.instance()
	$Map.add_child(g)
	g.global_position = player.global_position
	g.start_position = player.global_position
	g.end_position = shoot_dir

func spawnBullet(from, to) -> Node2D:
	var b = Bullet.instance()
	b.global_position = from
	b.target_pos = to
	$Map.add_child(b)
	return b

func spawnEnemy():
	if enemy_count >= MAX_ENEMY_COUNT:
		return
	else:
		enemy_count += 1
	var centerpos = $AreaSpawn/CollisionShape2D.position + $AreaSpawn.position
	var size  = int($AreaSpawn/CollisionShape2D.shape.radius)
	var positionInArea : Vector2
	positionInArea.x = (randi() % size) - (size/2) + centerpos.x
	positionInArea.y = (randi() % size) - (size/2) + centerpos.y

	var spawn = Enemy.instance()
	spawn.position = positionInArea
	$Map.add_child(spawn)

func _on_Timer_timeout() -> void:
	spawnEnemy()

func on_enemy_die():
	enemy_count -= 1
	if enemy_count < 0:
		enemy_count = 0


func _on_Player__on_player_death() -> void:
	$Control/Tween.interpolate_property($Control/Label,"visible_characters",0,11,2,Tween.TRANS_LINEAR)
	$Control/Tween.start()
	$AudioStreamPlayer.stream = load("res://assets/snd/snaake.wav")
	$AudioStreamPlayer.play()
	yield($AudioStreamPlayer,"finished")
	get_tree().reload_current_scene()

func _on_Player__on_grenade_ready() -> void:
	$Hud/Control/AnimHud.play("nate_ready")

func _on_Timer2_timeout() -> void:
	mts_to_finish -= 1
