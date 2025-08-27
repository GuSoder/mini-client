extends Node3D

@export var client_number: int = 1

var is_publisher: bool = false
var object_index: int = 0

func _ready():
	object_index = get_index()
	determine_role()
	
	var timer = Timer.new()
	timer.wait_time = 1.0  # Reduced from 0.01 to 1.0 second for easier debugging
	timer.timeout.connect(_update)
	timer.autostart = true
	add_child(timer)

func determine_role():
	var client_number_node: ClientNumber = get_node("../../../ClientNumber")
	if client_number_node:
		is_publisher = (client_number == client_number_node.client_number)
		print("NetworkedObject", object_index, " - Client:", client_number, " Scene:", client_number_node.client_number, " Publisher:", is_publisher)
		
		# Remove controller if this is a subscriber
		if not is_publisher:
			var controller = get_node_or_null("Controller")
			if controller:
				print("NetworkedObject", object_index, " - Removing controller (subscriber)")
				controller.queue_free()
	else:
		print("NetworkedObject", object_index, " - ERROR: Could not find ClientNumber node")

func _update():
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
	print("NetworkedObject", object_index, " - Publish result:", response_code, " Body:", body.get_string_from_utf8())
	var sender = get_children().back()
	if sender is HTTPRequest:
		sender.queue_free()

func _on_subscribe_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("NetworkedObject", object_index, " - Subscribe result:", response_code)
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var data = json.data
			print("NetworkedObject", object_index, " - Received data:", data)
			if data.has("pos_x") and data.has("pos_y") and data.has("pos_z") and data.has("rot_y"):
				set_position_rotation(data.pos_x, data.pos_y, data.pos_z, data.rot_y)
				print("NetworkedObject", object_index, " - Updated position to:", position)
		else:
			print("NetworkedObject", object_index, " - JSON parse error")
	else:
		print("NetworkedObject", object_index, " - HTTP error:", response_code)
	
	var sender = get_children().back()
	if sender is HTTPRequest:
		sender.queue_free()

func set_position_rotation(pos_x: float, pos_y: float, pos_z: float, rot_y: float):
	position = Vector3(pos_x, pos_y, pos_z)
	rotation.y = rot_y
