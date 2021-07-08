extends "res://Characther.gd"

onready var ai = load("AI.py")
#onready var player = preload("res://Player.tscn")

#onready var ai = $AI2


signal enemy_info(x_pos, health_bar, player_health_bar)
	
func _physics_process(delta):
#	print(ai)
	var player_x = get_parent().get_node('Player').global_position.x
#	print(player_x)
	emit_signal('enemy_info', player_x, 100, 100)
#	print(ai.a())

func _on_AI_controller_action(action):
	print(action)
