extends Node

onready var player : Player = $Player

func _ready() -> void:
	player.connect("_on_player_shoot",self,"on_player_shoot")

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
