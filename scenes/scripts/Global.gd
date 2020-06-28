extends Node

const DROPDOWN_MIN_Y = 299 # para poder saltar hacia abajo en plataformas
const UP_DIRECTION  = Vector2(0,-1)
const GRAVITY = Vector2(0,980)

const SOUNDS = {
	"shoot" : [
		preload("res://assets/snd/shoot1.wav")
	]
}

func _ready() -> void:
	pass

func getSound(name) -> AudioStream:
	var pool : Array = SOUNDS[name]
	return pool[randi()%pool.size()]
