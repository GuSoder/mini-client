extends Node3D

@export var radius: float = 2.0
@export var speed: float = 1.0

var center_position: Vector3
var time: float = 0.0

func _ready():
	center_position = get_parent().position

func _process(delta):
	time += delta * speed
	
	var offset = Vector3(
		cos(time) * radius,
		0,
		sin(time) * radius
	)
	
	get_parent().position = center_position + offset
