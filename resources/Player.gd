extends KinematicBody2D

signal died

enum State {NORMAL, DASHING }

export(int, LAYERS_2D_PHYSICS) var dashHazardMask

var gravity = 790
var velocity =Vector2.ZERO
var maxSpeed = 140
var maxDashSpeed = 500
var minDashSpeed = 200
var horizontalAcceleration = 2000
var JumpSpeed = 300
var JumpTerminationMultiplier = 4
var HasDoubleJump = false
var hasDash = false
var CurrentState = State.NORMAL
var isStateNew = true
var defaultHazardMask = 0

func _ready():
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")
	defaultHazardMask = $HazardArea.collision_mask

func _process(delta):
	var currentPosition = position
	
	if (currentPosition.y > 400):
		emit_signal("died")
	match CurrentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
	isStateNew = false
	
func change_state(newState):
	CurrentState = newState
	isStateNew = true
	
func process_normal(delta):
	if (isStateNew):
		$DashArea/CollisionShape2D.disabled = true
		$HazardArea.collision_mask = defaultHazardMask

	var moveVector = get_movement_vector()
	
	velocity.x += moveVector.x * horizontalAcceleration * delta
	if (moveVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
		
	velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
	
	if (moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || HasDoubleJump)):
		velocity.y = moveVector.y * JumpSpeed
		if (!is_on_floor() && $CoyoteTimer.is_stopped()):
			$"/root/Helpers".apply_camara_shake(.75)
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
		hasDash = true
	
	if (hasDash && Input.is_action_just_pressed("Dash")):
		call_deferred("change_state", State.DASHING)
		hasDash = false
	
	update_animation()

func process_dash(delta):
	if (isStateNew):
		$"/root/Helpers".apply_camara_shake(.75)
		$DashArea/CollisionShape2D.disabled = false
		$AnimatedSprite.play("jump")
		$HazardArea.collision_mask = dashHazardMask
		var moveVector = get_movement_vector()
		var velocityMod = 1
		if (moveVector.x != 0):
			velocityMod = sign(moveVector.x)
		else:
			velocityMod = 1 if $AnimatedSprite.flip_h else -1
		
		velocity = Vector2(maxDashSpeed * velocityMod, 0)

	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -8 * delta))
	
	if (abs(velocity.x) < minDashSpeed):
		call_deferred("change_state", State.NORMAL)

func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return moveVector

func update_animation():
	var moveVector = get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (moveVector.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
	if (moveVector.x != 0):
		$AnimatedSprite.flip_h = true if moveVector.x > 0 else false

func on_hazard_area_entered(_area2d):
	$"/root/Helpers".apply_camara_shake(1)
	emit_signal("died")
