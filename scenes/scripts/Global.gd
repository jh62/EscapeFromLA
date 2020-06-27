extends Node

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
