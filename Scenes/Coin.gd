extends Node2D

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")
	
func on_area_entered(Area2d):
	$AnimationPlayer.play("Pick Up")
	call_deferred("disable_pickup")

func _disable_pickup():
	$Area2D/CollisionShape2D.disabled = true
