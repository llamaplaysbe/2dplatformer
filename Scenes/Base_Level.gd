extends Node

var PlayerScene = preload("res://Scenes/Player.tscn")
var SpawnPosition =  Vector2.ZERO
var CurrentPlayerNode = null

func _ready():
	SpawnPosition = $Player.global_position
	register_player($Player)

func register_player(player):
	CurrentPlayerNode = player
	CurrentPlayerNode.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)

func create_player():
	var playerInstance = PlayerScene.instance()
	add_child_below_node(CurrentPlayerNode, playerInstance)
	playerInstance.global_position = SpawnPosition
	register_player(playerInstance)
	
func on_player_died():
	CurrentPlayerNode.queue_free()
	create_player()
