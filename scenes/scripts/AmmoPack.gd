extends KinematicBody2D


func _ready() -> void:
	action = funcref(self,"on_pickedup")
