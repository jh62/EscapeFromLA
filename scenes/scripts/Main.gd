extends Node

onready var player : Player = $Map/Player

func _ready() -> void:
	player.connect("_on_player_shoot",self,"on_player_shoot")

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
