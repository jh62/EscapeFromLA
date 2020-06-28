extends Node2D

signal _on_picked_up(this)

func _on_Area2D_body_entered(body: Node) -> void:
	emit_signal("_on_picked_up", self)
	$Area2D/CollisionShape2D.disabled = true
