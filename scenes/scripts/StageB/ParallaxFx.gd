extends ParallaxBackground

onready var bg = $ParallaxLayer
onready var wall = $ParallaxLayer2
onready var wave = $ParallaxLayer3

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	bg.motion_offset.x -= 1 * bg.motion_scale.x
	wall.motion_offset.x -= 1 * wall.motion_scale.x
	wave.motion_offset.x -= 1 * wave.motion_scale.x
