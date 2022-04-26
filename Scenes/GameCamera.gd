extends Camera2D

var targetPosition = Vector2.ZERO

export(Color, RGB) var backroundColor
export(OpenSimplexNoise) var shakeNoise

var xNoiseSampleVector = Vector2.RIGHT
var yNoiseSampleVector = Vector2.DOWN
var xNoiseSamplePostion = Vector2.ZERO
var yNoiseSamplePostion = Vector2.ZERO
var noiseSampleTravelRate = 300
var maxShakeOffset = 10
var currentShakePercentage = 0
var shakeDecay = 3

func _ready():
	VisualServer.set_default_clear_color(backroundColor)
	
func _process(delta):
	acquire_target_position()
	
	global_position = lerp(targetPosition, global_position, pow(2, -15 * delta))
	
	
	if(currentShakePercentage > 0):
		xNoiseSamplePostion += xNoiseSampleVector * noiseSampleTravelRate * delta
		yNoiseSamplePostion += yNoiseSampleVector * noiseSampleTravelRate * delta
		var xSample = shakeNoise.get_noise_2d(xNoiseSamplePostion.x, xNoiseSamplePostion.y)
		var ySample = shakeNoise.get_noise_2d(yNoiseSamplePostion.x, yNoiseSamplePostion.y)
		
		var calculatedOffset = Vector2(xSample, ySample) * maxShakeOffset * currentShakePercentage
		offset = calculatedOffset
		
		currentShakePercentage = clamp(currentShakePercentage - shakeDecay * delta, 0, 1)

func apply_shake(percentage):
	currentShakePercentage = clamp(currentShakePercentage + percentage, 0, 1)

func acquire_target_position():
	var players = get_tree().get_nodes_in_group("player")
	if (players.size() > 0):
		var player = players [0]
		targetPosition = player.global_position



