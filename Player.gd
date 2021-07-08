extends "res://Characther.gd"

const LASER_PROJECTILE = preload("res://LaserProjectile.tscn")

func _ready():
	state = {
		'walk' : false,
		'idle' : false,
		'crouch' : false,
		'jump' : false,
		'walk aiming gun' : false,
		'aim' : false,
		'shoot': false
	} 

func shoot():
	print(1)
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
		
func _physics_process(delta):
	gravity(delta)
	input(delta)

func input(delta):
	motion.x = 0
	var x_input = Input.get_action_strength("d") - Input.get_action_strength("a")

	## moving
	if x_input != 0:
		if x_input > 0:
			if sign($Position2D.position.x) == -1:
				$Position2D.position.x *= -1
		else:
			if sign($Position2D.position.x) == 1:		
				$Position2D.position.x *= -1
		
		if is_on_floor():
			sprite.flip_h = x_input > 0 
			if Input.is_action_pressed("shift"):
				run(x_input, delta)
			else:
				if Input.is_action_pressed("mouse_right"):
					walk_aiming_gun(x_input, delta)
				else:
					walk(x_input, delta)
		if Input.is_action_pressed("space") or state['jump']:
			if is_on_floor():
				var side = 1 if sprite.flip_h else -1
				jump_input = side
			jump(jump_input, delta)
	else:
		#not moving
		if Input.is_action_just_pressed("ctrl"):	
			if !state['crouch']:
				idle()
			else:
				crouch()
		else:
			if Input.is_action_just_pressed("space"):
				jump(x_input, delta)
			elif Input.is_action_pressed("mouse_right"):
				if Input.is_action_just_pressed("mouse_left"): # and timer.is_stopped():
					shoot()
				elif Input.is_action_just_released("mouse_left") or !state['shoot']:
					aim()
			else:				
				idle()




#	motion.x = 0
#	var x_input = Input.get_action_strength("d") - Input.get_action_strength("a")
#
#	## moving
#	if x_input != 0:
#		if is_on_floor():
#			if Input.is_action_just_pressed("space"):
#				jump(x_input, delta)
#	else:
#		#not moving
#		if Input.is_action_just_pressed("space"):
#			jump(x_input, delta)



