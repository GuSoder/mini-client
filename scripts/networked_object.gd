extends Node3D

@export var client_number: int = 1

var is_publisher: bool = false

func _ready():
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
	pass

func subscribe():
	pass
