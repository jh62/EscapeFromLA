extends Node2D


func _ready() -> void:
	$Node2D/Top.add_to_group("bounds")
	$Node2D/Bottom.add_to_group("bounds")
