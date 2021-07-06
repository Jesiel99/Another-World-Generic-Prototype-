extends KinematicBody2D

const WALK_SPEED = 4000
const RUN_SPEED = 12000
const JUMP_SPEED = 12000
const MAX_SPEED_WALK = 10000
const MAX_SPEED_RUN = 22000
const FRICTION = 0.9
const GRAVITY = 900
const JUMP_FORCE = 10000
const LASER_PROJECTILE = preload("res://LaserProjectile.tscn")

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

var jumping = false
	
func _physics_process(delta):
	gravity(delta)
	state_manager()
	animate(delta)

func state_manager():
	if !is_on_floor() and Input.is_action_just_pressed("space"):
		jumping = true
	if is_on_floor():
		jumping = false

func walk(x_input, delta):
	state_machine.travel("walk")	
	walk_movement(x_input, delta)
	set_state('walk', true) 

func walk_aiming_gun(x_input, delta):
	state_machine.travel("walk pointing gun")
	walk_movement(x_input, delta)
	set_state('walk aiming gun', true) 
	
func walk_movement(x_input, delta):
	x_movement(x_input, WALK_SPEED, delta)

func x_movement(x_input, speed, delta):
	motion.x = x_input * speed * delta
	motion.x = clamp(motion.x, -MAX_SPEED_WALK, MAX_SPEED_WALK)

func jump(x_input, delta):
	motion.y = -JUMP_FORCE * delta
	state_machine.travel("jump")
	jump_input = x_input		 
	set_state('jump', true) 

func shoot():
	state_machine.travel("shoot")
	var laser_projectile = LASER_PROJECTILE.instance()
	get_parent().add_child(laser_projectile)
	laser_projectile.position = $Position2D.global_position
	var side
	if sprite.flip_h:
		side = 1
	else:
		side = -1
	laser_projectile.speed = laser_projectile.speed * side
	set_state('shoot', true)

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
	
func animate(delta) -> void:
	motion.x = 0
	var x_input = Input.get_action_strength("d") - Input.get_action_strength("a")
	
	if !is_on_floor():
		motion.x = jump_input * JUMP_SPEED * delta
		motion.x = clamp(motion.x, -MAX_SPEED_WALK, MAX_SPEED_WALK)
	## moving
	if x_input != 0 or jumping:
		if x_input > 0:
			if sign($Position2D.position.x) == -1:
				$Position2D.position.x *= -1
				print(-1)
				print($Position2D.position.x)
		else:
			if sign($Position2D.position.x) == 1:		
				$Position2D.position.x *= -1
				print(1)
				print($Position2D.position.x)
			print(0)
		
						
		if is_on_floor():
			sprite.flip_h = x_input > 0 
			if Input.is_action_pressed("shift"):
				run(x_input, delta)
			else:
				if Input.is_action_pressed("mouse_right"):
					walk_aiming_gun(x_input, delta)
				else:
					walk(x_input, delta)
			if Input.is_action_just_pressed("space"):
				jump(x_input, delta)
	else:
		#not moving
		if Input.is_action_pressed("ctrl"):	
			if state_machine.get_current_node() == "crouch":
				idle()
			else:
				crouch()
		else:
			if Input.is_action_just_pressed("space"):
				jump(x_input, delta)
			if Input.is_action_pressed("mouse_right"):
				aim()
				if Input.is_action_just_pressed("mouse_left") and timer.is_stopped():
					shoot()
			else:
				idle()

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

