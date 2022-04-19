extends Node2D

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")
	
func on_area_entered(_area2d):
	$AnimationPlayer.play("Pick Up")
	call_deferred("disable_pickup")
	
	var baselevel = get_tree().get_nodes_in_group("base_level")[0]
	baselevel.coin_collected()

func _disable_pickup():
	$Area2D/CollisionShape2D.disabled = true
