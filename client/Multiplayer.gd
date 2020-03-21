extends Node

var client_id
var clients = []

var enemy = preload("res://Enemy.tscn")

var websocket_url = "ws://localhost:8080"
var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	_client.get_peer(1).put_packet("200,200".to_utf8())

func _on_data():
	var received_data = _client.get_peer(1).get_packet().get_string_from_utf8()
	var received_data_array = received_data.split(",")
	if received_data_array[0] == "myid":
		client_id = received_data_array[1]
	elif received_data_array[0] == "destroy":
		var clientIndex = 0
		for i in clients.size():
			if clients[i][0] == received_data_array[1]:
				clientIndex = i
				break
		clients[clientIndex][1].queue_free()
		clients.remove(clientIndex)
	elif received_data_array[0] != client_id:
		var is_in_clients = false
		var client_index = received_data_array[0]
		var client_x = int(received_data_array[1])
		var client_y = int(received_data_array[2])
		for i in range(clients.size()):
			if clients[i][0] == client_index:
				is_in_clients = true
				client_index = i
				break
		if is_in_clients:
			clients[client_index][1].position = Vector2(client_x, client_y)
		elif not(is_in_clients):
			var enemyInstance = enemy.instance()
			enemyInstance.position = Vector2(client_x, client_y)
			get_tree().get_root().add_child(enemyInstance)
			clients.append([client_index, enemyInstance])
		
	#print("Got data from server: ", received_data)
	#print(clients)

func _process(delta):
	_client.poll()
