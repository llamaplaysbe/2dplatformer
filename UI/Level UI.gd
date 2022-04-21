extends CanvasLayer

func _ready():
	var baselevels = get_tree().get_nodes_in_group("base_level")
	
	if (baselevels.size() > 0):
		baselevels[0].connect("coin_total_changed", self, "on_coin_total_changed")
	
func on_coin_total_changed(totalcoins, collectedCoins):
	$MarginContainer/HBoxContainer/CoinLabel.text = str( collectedCoins, "/", totalcoins)
