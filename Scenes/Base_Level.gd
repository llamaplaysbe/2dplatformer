extends Node

signal coin_total_changed

export(PackedScene) var levelCompleteScene

var PlayerScene = preload("res://Scenes/Player.tscn")
var SpawnPosition =  Vector2.ZERO
var currentPlayerNode = null
var totalCoins = 0
var collectedCoins = 0

func _ready():
	SpawnPosition = $Player.global_position
	register_player($Player)
	coin_total_changed(get_tree().get_nodes_in_group("coin").size())
	
	$Flag.connect("player_won", self, "on_player_won")

func coin_collected():
	collectedCoins += 1
	emit_signal("coin_total_changed", totalCoins, collectedCoins)
	
func coin_total_changed(NewTotal):
	totalCoins = NewTotal
	emit_signal("coin_total_changed", totalCoins, collectedCoins)

func register_player(player):
	currentPlayerNode = player
	currentPlayerNode.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)

func create_player():
	var playerInstance = PlayerScene.instance()
	add_child_below_node(currentPlayerNode, playerInstance)
	playerInstance.global_position = SpawnPosition
	register_player(playerInstance)
	
func on_player_died():
	currentPlayerNode.queue_free()
	create_player()

func on_player_won():
	currentPlayerNode.queue_free()
	var levelComplete = levelCompleteScene.instance()
	add_child(levelComplete)
		
	
	

