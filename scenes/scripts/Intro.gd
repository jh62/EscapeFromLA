extends VideoPlayer

export(PackedScene) var next

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if Global.intro_stageB_skipped:
		return

	if event.is_action_pressed("ui_cancel"):
		Global.intro_stageB_skipped = true
		$Tween.interpolate_property(self,"modulate",Color(1,1,1,1), Color(0,0,0,0),2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$Tween.start()

func _on_VideoPlayer_finished() -> void:
	changeScene()

func _on_Tween_tween_all_completed() -> void:
	changeScene()

func changeScene():
	get_tree().change_scene_to(next)
