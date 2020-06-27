extends KinematicBody2D

class_name Player

signal _on_hit(attacker)

enum STATES {
	IDLE,
	MOVING,
	RUNNING,
	JUMPING
	DIYING
}

export(float) var speed := 180.0

onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var audio = $AudioStreamPlayer
onready var timer_shoot : Timer = $TimerShoot
onready var raycast : RayCast2D = $RayCast2D

onready var current_state : State = IdleState.new(self) setget change_state

var vel := Vector2()
var dir := Vector2()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	current_state._process(delta)

func _physics_process(delta: float) -> void:
	current_state._physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	current_state.input(event)
#
	if event.is_action_pressed("ui_cancel"):
		global_position = Vector2(20,20)
		current_state = IdleState.new(self)

func change_state(new_state : State) -> void:
	if new_state != current_state:
		current_state = new_state

func is_shooting() -> bool:
	return !$TimerShoot.is_stopped()

func shoot():
	$TimerShoot.start(.1)
	$MuzzlePos/Sprite_Muzzle.visible = true
#	$MuzzlePos/Sprite_Muzzle.frame = 0
	$MuzzlePos/Sprite_Muzzle.play("fire")
	audio.stream = Global.getSound("shoot")
	audio.play()

	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		connect("_on_hit",collider,"on_hit")
		emit_signal("_on_hit",self)

func _on_TimerShoot_timeout() -> void:
	$MuzzlePos/Sprite_Muzzle.visible = false

#Inner-classes
class State:
	var player : Player

	func _init(p):
		player = p
	func _process(delta : float) -> void:
		pass
	func _physics_process(delta : float) -> void:
		pass
	func input(event: InputEvent) -> void:
		pass

class IdleState extends State:
	func _init(p).(p) -> void:
		pass

	func _process(delta):
		if player.vel.x != 0:
			player.anim_player.play("run_e" if player.dir.x > 0 else "run_w")
		else:
			player.anim_player.play("idle_e" if player.dir.x > 0 else "idle_w")

	func _physics_process(delta):
		player.move_and_slide((player.vel + Global.GRAVITY) * player.speed, Vector2(0,-1))

	func input(event : InputEvent):
		if event.is_action_pressed("jump") && player.is_on_floor():
			var state := JumpState.new(player, event.get_action_strength("jump"))
			player.change_state(state)
			return

		if !player.is_shooting() && event.is_action_pressed("shoot"):
			player.shoot()

		# si usas event tiene un delay feo... que onda?
		var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
		if dir != 0:
			player.dir.x = dir

		player.vel.x = dir

class JumpState extends State:
	onready var jump_force = Vector2()

	func _init(p, force).(p) -> void:
		jump_force = Vector2(p.vel.x, -8 * force)

	func _process(delta):
		player.anim_player.play("jump_e" if player.dir.x > 0 else "jump_w")

	func _physics_process(delta):
		player.move_and_slide((player.vel + jump_force) * player.speed,Global.UP_DIRECTION)
		jump_force.x = lerp(jump_force.x, 0, .01)
		jump_force.y = lerp(jump_force.y, Global.GRAVITY.y, .05)

		if player.is_on_floor():
			if  !Input.is_action_pressed("right") && !Input.is_action_pressed("left"):
				player.vel.x = 0
			var state := IdleState.new(player)
			player.change_state(state)
			return

	func input(event : InputEvent):
		pass

