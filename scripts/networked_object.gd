extends Node3D

@export var client_number: int = 1

var is_publisher: bool = false
var object_index: int = 0

func _ready():
	object_index = get_index()
	
	var timer = Timer.new()
	timer.wait_time = 0.01
	timer.timeout.connect(_check_role)
	timer.autostart = true
	add_child(timer)

func _check_role():
	var client_number_node: ClientNumber = get_node("../../ClientNumber")
	if client_number_node:
		is_publisher = (client_number == client_number_node.client_number)
		
	if is_publisher:
		publish()
	else:
		subscribe()

func publish():
	var data = {
		"pos_x": position.x,
		"pos_y": position.y, 
		"pos_z": position.z,
		"rot_y": rotation.y
	}
	print("Publishing object ", object_index, ": ", data)

func subscribe():
	pass

func set_position_rotation(pos_x: float, pos_y: float, pos_z: float, rot_y: float):
	position = Vector3(pos_x, pos_y, pos_z)
	rotation.y = rot_y
