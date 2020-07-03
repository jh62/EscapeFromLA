extends Node

const DROPDOWN_MIN_Y = 299 # para poder saltar hacia abajo en plataformas
const UP_DIRECTION  = Vector2(0,-1)
const GRAVITY = Vector2(0,980)

enum BulletType {
	PLAYER,
	ENEMY
}

const SOUNDS = {
	"shoot" : [
		preload("res://assets/snd/shoot-02.wav")
	],
	"reload" : [
		preload("res://assets/snd/rld.wav")
	],
	"impact" : [
		preload("res://assets/snd/impact-01.wav"),
		preload("res://assets/snd/impact-02.wav")
	],
	"hurt" : [
		preload("res://assets/snd/hurt-01.wav"),
		preload("res://assets/snd/hurt-02.wav"),
		preload("res://assets/snd/hurt-03.wav"),
		preload("res://assets/snd/hurt-04.wav"),
		preload("res://assets/snd/hurt-05.wav"),
		preload("res://assets/snd/hurt-06.wav"),
		preload("res://assets/snd/hurt-07.wav"),
		preload("res://assets/snd/hurt-08.wav")
	],
	"die" : [
		preload("res://assets/snd/die-01.wav"),
		preload("res://assets/snd/die-02.wav"),
		preload("res://assets/snd/die-03.wav")
	],
	"knows" : [
		preload("res://assets/snd/knows-01.wav"),
		preload("res://assets/snd/knows-02.wav"),
		preload("res://assets/snd/knows-03.wav")
	],
	"dry" : [
		preload("res://assets/snd/dry.wav")
	]
}

var intro_skipped = false
var intro_stageB_skipped = false

func _ready() -> void:
	pass

func getSound(name) -> AudioStream:
	var pool : Array = SOUNDS[name]
	return pool[randi()%pool.size()]
