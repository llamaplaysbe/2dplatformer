extends KinematicBody2D

func _ready():
	pass # Replace with function body.

func _process(delta):
	move_and_slide(Vector2(0, 1))
