extends KinematicBody2D

class_name Player

signal _on_shoot(this, pos,dir)
signal _on_death

export(int) var health := 100
export(float) var speed := 180.0
export(float) var damage := 25
export(int) var max_bullets := 20
export(float) var shoot_delay := .75

onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var audio = $AudioStreamPlayer
onready var timer_shoot : Timer = $Timer
onready var raycast : RayCast2D = $RayCast2D
onready var shape : CollisionShape2D = $CollisionShape2D
onready var reload_timer : Timer = $Timer2

onready var current_state : State = IdleState.new(self) setget change_state
onready var shoot_sound = preload("res://assets/snd/shoot-02.wav")

var bullets := 20
var vel := Vector2()
var dir := Vector2(1,0)
var knockback := Vector2(0,0)
var dry = false

func _ready() -> void:
	add_to_group("player")
	shape.one_way_collision = true
	$MuzzlePos/Sprite_Muzzle.visible = false
	pass

func _process(delta: float) -> void:
	current_state._process(delta)

	if !(current_state is DeathState) && global_position.y > 352:
		current_state = DeathState.new(self)

func _physics_process(delta: float) -> void:
	current_state._physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	current_state.input(event)

func change_state(new_state : State) -> void:
	if new_state != current_state:
		current_state = new_state

func is_shooting() -> bool:
	return !$Timer.is_stopped()

func is_reloading()->bool:
	return !reload_timer.is_stopped()

func shoot():
	if bullets == 0:
		if !dry:
			dry = true
			audio.stream = Global.getSound("dry")
			audio.pitch_scale = rand_range(.97,1)
			audio.play()
		return

	knockback = Vector2(25,0) * -dir
	consume_bullet()
	emit_signal("_on_shoot",self, $BulletPos.global_position, dir)
	$Timer.start(shoot_delay)
	$MuzzlePos/Sprite_Muzzle.visible = true
	$Timer3.start()
#	audio.stream = Global.getSound("shoot")
	audio.stream = shoot_sound
	audio.pitch_scale = rand_range(.97,1)
	audio.play()

func on_hit(attacker,target) -> void:
	if target != self:
		return
	if current_state is DeathState:
		return

	health -= attacker.damage
	$BloodFX.one_shot = true
	$BloodFX.visible = true
	$BloodFX.emitting = true
	if health <= 0:
		current_state = DeathState.new(self)
		return
	else:
		$AudioStreamPlayer.stream = Global.getSound("hurt")
		$AudioStreamPlayer.pitch_scale = 1.0
		$AudioStreamPlayer.play()

func consume_bullet() -> void:
	bullets -= 1
	if bullets < 0:
		bullets = 0

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
	var reloading = false

	func _init(p).(p) -> void:
		pass

	func _process(delta):
		if player.vel.x != 0:
			if Input.is_action_pressed("left") || Input.is_action_pressed("right"):
				player.anim_player.play("run_e" if player.dir.x > 0 else "run_w")
			else:
				player.anim_player.play("idle_e" if player.dir.x > 0 else "idle_w")
		else:
			player.anim_player.play("idle_e" if player.dir.x > 0 else "idle_w")

		#Todo esto lo saque de input ya que esa funcion solo se ejecuta si hay algun evento
		#Eso hacía que si yo mantenia una tecla presionada y no cambiaba nada, al caer al suelo
		#a veces la velocidad estaba mal
		if Input.is_action_just_pressed("jump") && player.is_on_floor():
			if Input.is_action_pressed("down") && player.global_position.y < Global.DROPDOWN_MIN_Y:
				player.shape.disabled = true
				yield(player.get_tree().create_timer(.1),"timeout")
				player.shape.disabled = false
			else :
				var state := JumpState.new(player, Input.get_action_strength("jump"))
				player.change_state(state)
				return

		if !player.is_shooting() && !player.is_reloading() && (Input.is_action_pressed("shoot") || Input.is_action_pressed("shoot_joy")):
			player.shoot()


		# si usas event tiene un delay feo... que onda?
		var dir = Input.get_action_strength("right") - Input.get_action_strength("left")

		if dir != 0:
			player.dir.x = dir

		player.vel.x = dir*player.speed
		# Agregué esto simplemente para que no quede la animación de correr mientras caes cuando te caiste por un borde
		if !player.is_on_floor():
			var state := JumpState.new(player, 0)
			player.change_state(state)
			return

	func _physics_process(delta):
		player.vel += Global.GRAVITY*delta
		player.vel+= player.knockback
		player.vel = player.move_and_slide(player.vel, Global.UP_DIRECTION)

		if player.knockback != Vector2.ZERO:
			player.knockback = lerp(player.knockback,Vector2.ZERO,(5 if player.is_shooting() else 25) * delta)
			if player.knockback.length() < .1:
				player.knockback = Vector2.ZERO

#		if player.get_slide_count() > 0:
#			if player.get_slide_collision(0).collider is Item:
#				pass
	func input(event: InputEvent) -> void:
		if event.is_action_pressed("reload") && player.bullets < player.max_bullets && player.reload_timer.is_stopped():
			player.reload_timer.start()
			player.audio.stream = Global.getSound("reload")
			player.audio.play()

class JumpState extends State:
	onready var jump_force = Vector2()

	func _init(p, force).(p) -> void:
		jump_force = Vector2(0, -500 * force)
		player.vel += jump_force

	func _process(delta):
		player.anim_player.play("jump_e" if player.dir.x > 0 else "jump_w")

	func _physics_process(delta):
		# move_and_slide devuelve la velocidad correcta luego del calculos de colisiones.
		# hay que actualizar la variable de velocidad de esa forma, sino se sigue acumulando la gravedad
		# y cuando caigas de un borde vas a caer muy rápido
		# Además, move and slide toma como parámetro una velocidad, ya que internamente
		# multiplica por delta para obtener la posicion. Por lo tanto, la gravedad la debemos
		# multiplicar por delta para transformarla en velocidad, antes de sumarla. Esto asegura que el
		# movimiento sesa consistente entre frames.
		player.vel += Global.GRAVITY*delta
		player.vel = player.move_and_slide((player.vel),Global.UP_DIRECTION)


		if player.is_on_floor():
			if  !Input.is_action_pressed("right") && !Input.is_action_pressed("left"):
				player.vel.x = 0
			var state := IdleState.new(player)
			player.change_state(state)
			return
		else:
			#saque lo del force en x en physics y agregué esto aca para darle mas control al salto
			var dir : int = 0
			if  Input.is_action_pressed("right"):
				dir += 1
			elif Input.is_action_pressed("left"):
				dir -= 1
			player.vel.x = lerp(player.vel.x, dir*player.speed, 0.05)


	func input(event : InputEvent):
		pass

class DeathState extends State:
	var dead = false

	func _init(p).(p) -> void:
		player.vel = Vector2.ZERO
		player.set_collision_layer_bit(1,false)

	func _process(delta):
		if dead:
			return

		dead = true
		player.anim_player.play("die_e" if player.dir.x > 0 else "die_w")
		player.audio.stream = load("res://assets/snd/scream.wav")
		player.audio.play()
		yield(player.anim_player,"animation_finished")
		if player.audio.playing:
			yield(player.audio,"finished")
		player.emit_signal("_on_death")

	func _physics_process(delta):
		if !player.is_on_floor():
			player.vel += Global.GRAVITY*delta
			player.vel = player.move_and_slide((player.vel),Global.UP_DIRECTION)

	func input(event : InputEvent):
		pass

class GlideState extends State:
	var glider : KinematicBody2D
	var vel = Vector2(100,-10)
	func _init(p, g).(p):
		glider = g

	func _process(delta) -> void:
		vel.y += 20 * delta
		vel = glider.move_and_slide(vel)
		player.global_position = glider.global_position

func _on_Glider__on_picked_up(glider) -> void:
	$AnimationPlayer.play("jump_e")
	var state = GlideState.new(self,glider)
	change_state(state)


func _on_Timer2_timeout() -> void:
	bullets = max_bullets


func _on_Timer3_timeout() -> void:
	$MuzzlePos/Sprite_Muzzle.visible = false
