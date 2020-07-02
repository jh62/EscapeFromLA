extends StaticBody2D

var direction = "up"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if $AreaElevator.get_overlapping_bodies().size() == 0:
		return

	if $AnimationPlayer.is_playing():
		return

	if event.is_action_pressed("up"):
		if direction == "up":
			$AnimationPlayer.play("up")
		else:
			$AnimationPlayer.play("down")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "up" && $AreaElevator.get_overlapping_bodies().size() == 0:
		$AnimationPlayer.play("down")

	if anim_name == "up":
		direction = "down"
	elif anim_name == "down":
		direction = "up"
