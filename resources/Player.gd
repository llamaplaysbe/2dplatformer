extends KinematicBody2D

signal died

enum State {NORMAL, DASHING }

var gravity = 790
var velocity =Vector2.ZERO
var maxSpeed = 140
var horizontalAcceleration = 2000
var JumpSpeed = 300
var JumpTerminationMultiplier = 4
var HasDoubleJump = false
var CurrentState = State.NORMAL

func _ready():
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")

func _process(delta):
	match CurrentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			pass
	


func process_normal(delta):
	var moveVector = _get_movement_vector()
	
	velocity.x += moveVector.x * horizontalAcceleration * delta
	if (moveVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
		
	velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
	
	if (moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || HasDoubleJump)):
		velocity.y = moveVector.y * JumpSpeed
		if (!is_on_floor() && $CoyoteTimer.is_stopped()):
			HasDoubleJump = false
		$CoyoteTimer.stop()
		
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * JumpTerminationMultiplier * delta
	else: 
		velocity.y += gravity * delta
	
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if (wasOnFloor && !is_on_floor()):
		$CoyoteTimer.start()
	
	if (is_on_floor()):
		HasDoubleJump = true
	
	update_animation()

func _get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return moveVector

func update_animation():
	var moveVector = _get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (moveVector.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
	if (moveVector.x != 0):
		$AnimatedSprite.flip_h = true if moveVector.x > 0 else false

func on_hazard_area_entered(area2d):
	emit_signal("died")





