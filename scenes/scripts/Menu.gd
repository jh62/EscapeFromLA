extends Control

var pointer_pos := 0

onready var option_container = $CenterContainer/HBoxContainer/VBoxIcon
onready var pointer = $CenterContainer/HBoxContainer/VBoxIcon/Icon
onready var empty1 = $CenterContainer/HBoxContainer/VBoxIcon/Empty1
onready var empty2 = $CenterContainer/HBoxContainer/VBoxIcon/Empty2
onready var next_scene : PackedScene

var state = "menu"

func _ready() -> void:
	if !Global.intro_skipped:
		next_scene = load("res://scenes/Intro.tscn")
	else:
		next_scene = load("res://scenes/Main.tscn")

func _input(event: InputEvent) -> void:
	match state:
		"menu":
			if event.is_action_pressed("ui_up"):
				pointer_pos -= 1
			elif event.is_action_pressed("ui_down"):
				pointer_pos += 1
			elif event.is_action_pressed("ui_select"):
				match pointer_pos:
					1:
						showCredits()
					2:
						get_tree().quit(0)
					_:
						changeScene()
			if pointer_pos < 0:
				pointer_pos = 2
			elif pointer_pos > 2:
				pointer_pos = 0
			orderMenu()
		"credits":
				if event.is_action_pressed("ui_cancel"):
					showMenu()
func showMenu():
	$Tween.stop_all()
	state = "menu"
	if $TextureRect.modulate.a < 1.0:
		$Tween.interpolate_property($TextureRect,"modulate",Color(1,1,1,0),Color(1,1,1,1),2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	if $CenterContainer.modulate.a < 1.0:
		$Tween.interpolate_property($CenterContainer,"modulate",Color(1,1,1,0),Color(1,1,1,1),2,Tween.TRANS_LINEAR,Tween.EASE_IN)
	if $Control1.modulate.a > 0:
		$Control1.modulate.a = 0
	if $Control2.modulate.a > 0:
		$Control2.modulate.a = 0
	$Tween.start()

func showCredits():
	$Tween.stop_all()
	state = "credits"
	var fade_in_delay = 2
	var fade_out_delay = 4
	$Control1.visible = true
	$Control2.visible = true
	$Tween.interpolate_property($TextureRect,"modulate",Color(1,1,1,1),Color(1,1,1,0),fade_out_delay,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.interpolate_property($CenterContainer,"modulate",Color(1,1,1,1),Color(1,1,1,0),fade_out_delay,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.interpolate_property($Control1,"modulate",Color(1,1,1,0),Color(1,1,1,1),fade_in_delay,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_completed")
	yield(get_tree().create_timer(3),"timeout")
	if state != "credits":
		return
	$Tween.interpolate_property($Control1,"modulate",Color(1,1,1,1),Color(1,1,1,0),fade_out_delay,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.interpolate_property($Control2,"modulate",Color(1,1,1,0),Color(1,1,1,1),fade_in_delay,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_completed")
	yield(get_tree().create_timer(3),"timeout")
	if state != "credits":
		return
	$Tween.interpolate_property($Control2,"modulate",Color(1,1,1,1),Color(1,1,1,0),fade_out_delay,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$TextureRect.modulate = Color(1,1,1,1)
	$CenterContainer.modulate = Color(1,1,1,1)
	$Tween.start()
	yield($Tween,"tween_completed")
	if state != "credits":
		return
	showMenu()

func changeScene() -> void:
	get_tree().change_scene_to(next_scene)

func orderMenu():
	for c in option_container.get_children():
		option_container.remove_child(c)
	match pointer_pos:
		1:
			option_container.add_child(empty1)
			option_container.add_child(pointer)
			option_container.add_child(empty2)
		2:
			option_container.add_child(empty1)
			option_container.add_child(empty2)
			option_container.add_child(pointer)
		_:
			option_container.add_child(pointer)
			option_container.add_child(empty1)
			option_container.add_child(empty2)
