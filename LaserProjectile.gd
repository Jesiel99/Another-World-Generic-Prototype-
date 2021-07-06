extends Node2D

var speed = 1000
var velocity = Vector2()

func _physics_process(delta):
	velocity.x = speed * delta
	translate(velocity)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
