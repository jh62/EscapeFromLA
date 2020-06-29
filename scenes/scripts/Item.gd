extends StaticBody2D

class_name Item

func _ready() -> void:
	add_to_group("item")

func on_hit(attacker) -> void:
	print("item hit")
