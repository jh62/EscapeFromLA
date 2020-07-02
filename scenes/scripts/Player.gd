extends KinematicBody2D

class_name Player

signal _on_shoot(this, pos,dir)

enum STATES {
	IDLE,
	MOVING,
	RUNNING,
	JUMPING
	DIYING
}

export(int) var health := 100
export(float) var speed := 180.0
export(float) var damage := 25

onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var audio = $AudioStreamPlayer
onready var timer_shoot : Timer = $Timer
onready var raycast : RayCast2D = $RayCast2D
onready var shape : CollisionShape2D = $CollisionShape2D

onready var current_state : State = IdleState.new(self) setget change_state

var vel := Vector2()
var dir := Vector2()
var knockback := Vector2(25,0)

func _ready() -> void:
	add_to_group("player")
	shape.one_way_collision = true
	$MuzzlePos/Sprite_Muzzle.visible = false
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
	return !$Timer.is_stopped()

func shoot():
	emit_signal("_on_shoot",self, $BulletPos.global_position, dir)
	$Timer.start(.05)
	$MuzzlePos/Sprite_Muzzle.visible = true
	audio.stream = Global.getSound("shoot")
	audio.pitch_scale = rand_range(.97,1)
	audio.play()

func on_hit(attacker,target) -> void:
	if target != self:
		return

	health -= attacker.damage
	$BloodFX.one_shot = true
	$BloodFX.visible = true
	$BloodFX.emitting = true
	if health <= 0:
#		current_state = STATES.DIYING
		vel = Vector2.ZERO
		if dir.x < 0:
			$AnimationPlayer.play("die_w")
		else:
			$AnimationPlayer.play("die_e")
		return
	else:
		$AudioStreamPlayer.stream = Global.getSound("hurt")
		$AudioStreamPlayer.pitch_scale = 1.0
		$AudioStreamPlayer.play()

func _on_Timer_timeout() -> void:
	$MuzzlePos/Sprite_Muzzle.visible = false
	pass

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
			if Input.is_action_pressed("left") || Input.is_action_pressed("right"):
				player.anim_player.play("run_e" if player.dir.x > 0 else "run_w")
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

		if !player.is_shooting() && Input.is_action_just_pressed("shoot"):
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
		if player.is_shooting():
			player.vel+= player.knockback * -player.dir.x
		player.vel = player.move_and_slide(player.vel, Global.UP_DIRECTION)

#		if player.get_slide_count() > 0:
#			if player.get_slide_collision(0).collider is Item:
#				pass

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
	var state = GlideState.new(self,glider)
	change_state(state)
