extends Node2D


onready var Crosshair = preload("res://assets/stageB/crosshair.png")
onready var Bullet = preload("res://scenes/entities/StageB/Bullet2.tscn")
onready var Grenade = preload("res://scenes/entities/Grenade.tscn")
onready var Enemy = preload("res://scenes/entities/StageB/EnemySurfer.tscn")
onready var m_waveMusic = preload("res://assets/music/thewave.ogg")

export(int) var MAX_ENEMY_COUNT = 12

onready var player = find_node("Player")
var enemy_count = 0

func _ready() -> void:
	$Map/Top.add_to_group("bounds")
	$Map/Bottom.add_to_group("bounds")
	Input.set_custom_mouse_cursor(Crosshair, 0, Vector2(16,18))
	$AudioStreamPlayer2.play()
	$AudioStreamPlayer2.stream_paused = true
func _process(delta: float) -> void:
	if $AudioStreamPlayer.playing:
		if $AudioStreamPlayer.get_playback_position() >= 5.9:
			$AudioStreamPlayer2.stream_paused = false
			$Timer.start()
	print($AudioStreamPlayer.get_playback_position())

func _on_Player__on_shoot(pos : Vector2) -> void:
	var bullet = spawnBullet(pos, get_global_mouse_position())
	bullet.type = Global.BulletType.PLAYER

func on_enemy_shoot(pos : Vector2) -> void:
	var bullet = spawnBullet(pos, player.global_position)
	bullet.type = Global.BulletType.ENEMY

func _on_Player__on_grenade_throw(throw_pos) -> void:
	var g = Grenade.instance()
	g.global_position = throw_pos
	g.target_pos = get_global_mouse_position()
	$Map.add_child(g)

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
