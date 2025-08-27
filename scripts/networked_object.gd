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
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var json_string = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	var url = "http://localhost:5000/object/" + str(object_index)
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	http_request.request_completed.connect(_on_publish_completed)

func subscribe():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var url = "http://localhost:5000/object/" + str(object_index)
	
	http_request.request(url)
	http_request.request_completed.connect(_on_subscribe_completed)

func _on_publish_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var sender = get_children().back()
	if sender is HTTPRequest:
		sender.queue_free()

func _on_subscribe_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var data = json.data
			if data.has("pos_x") and data.has("pos_y") and data.has("pos_z") and data.has("rot_y"):
				set_position_rotation(data.pos_x, data.pos_y, data.pos_z, data.rot_y)
	
	var sender = get_children().back()
	if sender is HTTPRequest:
		sender.queue_free()

func set_position_rotation(pos_x: float, pos_y: float, pos_z: float, rot_y: float):
	position = Vector3(pos_x, pos_y, pos_z)
	rotation.y = rot_y
