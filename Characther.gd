extends KinematicBody2D

const WALK_SPEED = 4000
const RUN_SPEED = 12000
const JUMP_SPEED = 13000
const MAX_SPEED_WALK = 10000
const MAX_SPEED_RUN = 22000
const FRICTION = 0.9
const GRAVITY = 500
const JUMP_FORCE = 1000

var motion = Vector2.ZERO
var state = {
	'walk' : false,
	'idle' : false,
	'crouch' : false,
	'jump' : false,
	'walk aiming gun' : false,
	'aim' : false
} 

onready var sprite = $AnimatedSprite
onready var anim_tree = $AnimationTree
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var animation_player = get_node("AnimationPlayer")
onready var timer : Timer = $Timer

export var fire_rate : = 5 setget set_fire_rate
	
func _physics_process(delta):
	gravity(delta)
	input(delta)

func walk(x_input, delta):
	state_machine.travel("walk")	
	walk_movement(x_input, delta)
	set_state('walk', true) 

func walk_aiming_gun(x_input, delta):
	state_machine.travel("walk aiming gun")
	walk_movement(x_input, delta)
	set_state('walk aiming gun', true) 
	
func walk_movement(x_input, delta):
	x_movement(x_input, WALK_SPEED, delta)

func x_movement(x_input, speed, delta):
	motion.x = x_input * speed * delta
	motion.x = clamp(motion.x, -MAX_SPEED_WALK, MAX_SPEED_WALK)
	

func jump(x_input, delta):
	motion.y = -JUMP_FORCE * delta
	x_movement(x_input, JUMP_SPEED, delta)
	state_machine.travel("jump") 
	set_state('jump', true) 

func aim():
	state_machine.travel("aim")
	set_state('aim', true) 	

func idle():
	state_machine.travel("idle")
	set_state('idle', true) 
	$Standing.disabled = true
	$Crawling.disabled = false
	
func crouch():
	state_machine.travel("crouch")
	set_state('crouch', true) 
	$Standing.disabled = false
	$Crawling.disabled = true
	
func run(x_input, delta):
	motion.x = x_input * RUN_SPEED * delta
	motion.x = clamp(motion.x, -MAX_SPEED_RUN, MAX_SPEED_RUN)
	state_machine.travel("run")
	
func input(delta) -> void:
	pass

func gravity(delta):
	motion.y += GRAVITY * delta
	motion = move_and_slide(motion, Vector2.UP)

var jump_input = 0

func set_fire_rate(value):
	fire_rate = value
	timer.wait_time = 1 / fire_rate

func set_state(key, value):
	for i in state.size(): 
		state[state.keys()[i]] = false 
	state[key] = value
