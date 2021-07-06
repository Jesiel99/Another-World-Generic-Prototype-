extends KinematicBody2D

const ACCELERATION = 7000
const ACCELERATION_RUN = 9000
const MAX_SPEED_WALK = 600
const MAX_SPEED_RUN = 22000
const FRICTION = 0.9
const GRAVITY = 900
const JUMP_FORCE = 15000

var motion = Vector2.ZERO

onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var player = get_node("/root/World/Player")

var crawl = false

	
func _physics_process(delta):
	## move(delta)
	gravity(delta)
	
	if player:
		var direction = (player.position - position).normalized()
		move_and_slide(direction * MAX_SPEED_WALK)
	
		
func gravity(delta):
	motion.y += GRAVITY * delta
	motion = move_and_slide(motion, Vector2.UP)
		
	

	


