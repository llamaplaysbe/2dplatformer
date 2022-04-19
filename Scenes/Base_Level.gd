extends Node

signal coin_total_changed

var PlayerScene = preload("res://Scenes/Player.tscn")
var SpawnPosition =  Vector2.ZERO
var CurrentPlayerNode = null
var totalCoins = 0
var collectedCoins = 0

func _ready():
	SpawnPosition = $Player.global_position
	register_player($Player)
	
	coin_total_changed(get_tree().get_nodes_in_group("coin").size())

func coin_collected():
	collectedCoins += 1
	emit_signal("coin_total_changed", totalCoins, collectedCoins)
	
func coin_total_changed(NewTotal):
	totalCoins = NewTotal
	emit_signal("coin_total_changed", totalCoins, collectedCoins)

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
