extends KinematicBody2D

onready var multiplayerNode = get_tree().get_root().get_node("./World/Multiplayer")

var oldPosition = Vector2()
var velocity = Vector2()
var moveSpeed = 400
var jumpSpeed = 900
var gravity = 50

func _physics_process(delta):
	oldPosition = Vector2(position.x, position.y)
	velocity.x = lerp(velocity.x, 0, 0.3)
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -moveSpeed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = moveSpeed
	if is_on_floor() && Input.is_action_pressed("ui_select"):
		velocity.y = -jumpSpeed
		
	velocity.y += gravity
		
	velocity = move_and_slide(velocity, Vector2(0, -1))

	if oldPosition != position:
		var positionString = str(position.x) + "," + str(position.y)
		multiplayerNode._client.get_peer(1).put_packet(positionString.to_utf8())
