extends CharacterBody2D

enum State {Standing, Jumping, Rising, Midair, Falling, Dashing, Walling, Fastfalling, Dying, Crouching}
enum Action {None, Dash, Jump}

signal hearts_update(health: int)
signal change_checkpoint()
signal restart()
signal dash_time_update(time: float)

@export_group("Horizontal Mouvement")
## Maximum lateral speed for the player
@export var max_speed := 600.0
## Acceleration of the player. Higher value will give more reactivity, lower value will feel like walking on ice
@export var strength := 3000.0
## Midair acceleration of the player. How well can the player change its direction when in the air
@export var midair_strength := 800.0
## Velocity below which it goes to 0
@export var zero_velocity_margin := 10.0

@export_group("Vertical Movement")
@export_subgroup("Gravity and Aerial Trajectory")
## Gravity for the player
@export var gravity := 1100.0
## Gravity for the player when at the highest point of his jump, allows for a more pleasant jump
@export var midair_gravity := 600.0
## Limit defining when is the highest point of the jump, in purcentage of the initial velocity of the jump. Lower values will result in more natural jumps, higher values will give more "flying" jumps
@export_range(0,1) var midair_limit := 0.3
## Downward maximal velocity for the player
@export var max_fall_speed := 1500.0
@export_subgroup("Wall physics")
## Gravity for the player when he is sticking on a wall
@export var wall_gravity := 100.0
## Purcentage of max velocity jump when jumping from a wall
@export_range(0,1) var wall_velocity_reduction := 0.8

@export_group("Actions")
@export_subgroup("Crouch")
## Maximum lateral speed for the player when crouching
@export var crouch_max_speed := 200.0
## Gravity for the player when he crouches in the air
@export var fast_gravity := 3000.0
@export_subgroup("Dash")
## Time before the player is able to dash again
@export var dash_time := 3.0
## Speed of the dash
@export var dash_speed := 2000.0
## Duration of the dash
@export var dash_length := 0.2

@export_subgroup("Jump")
## Minimal jump velocity, if the jump key is immediatly released
@export var jump_velocity_min := 500.0
## Maximal jump velocity, if the jump key is never released
@export var jump_velocity_max := 1000.0
## Time to press the jump key to get the highest jump possible, in milliseconds
@export var allowed_jumping_time := 200.0

@export_group("Interactions")
## Strength of the knockback received when touching a dangerous object
@export var knockback := 600.0
## Strength to push objects
@export var push_strength := 100.0

@export_group("Advanced")
## Time frame the player has to buffer an action
@export var buffer_time = 0.4
## Time frame where the player can jump after leaving ground, in milliseconds
@export var ground_approximation = 100
## Pack scene, packing the player
@export var pack: Node2D
## Camera following the player
@export var camera: Node2D


@onready var dashTimer: Timer = get_node("DashTimer")

## STATES
var _begin_jump_time: int
var _end_jump_time: int
var _last_jump_velocity: float
var _state: State
var _buffer: Action 
var _left_wall: bool
var _right_wall: bool
var _last_time_on_ground: int
var _health: int
var _hurt: bool
var _direction: int

## INIT
func _ready() -> void:
	init()
func init():
	$Buffer.wait_time = buffer_time
	$DashTimer.wait_time = dash_time
	start_level()
	

## BUFFER TIMEOUT
func on_buffer_timeout():
	_buffer = Action.None

## CUSTOM IS_ON_GROUND
func is_on_ground():
	return Time.get_ticks_msec() < _last_time_on_ground + ground_approximation

## START LEVEL
func start_level():
	$AnimationPlayer.play("RESET")
	_hurt = false
	$DashTimer.stop()
	collision_mask = 34
	position = Vector2.ZERO
	velocity = Vector2.ZERO
	_state = State.Fastfalling
	_buffer = Action.None
	_last_jump_velocity = jump_velocity_max
	_health = 3
	hearts_update.emit(3)


## DAMAGE
func on_hitbox_entered(body: Node2D):
	if body.collision_layer & 8:
		die()
	elif body.collision_layer & 4:
		get_hurt()
func get_hurt():
	if _state == State.Dashing:
		return
	if _hurt: 
		return
	_health -= 1
	velocity = - velocity.normalized() * knockback
	velocity.x *= 1.5
	hearts_update.emit(_health)
	if _health == 0:
		die()
	else:
		_hurt = true
		if _state == State.Crouching:
			$AnimationPlayer.play("RESET")
			_state = State.Standing
		$AnimationPlayer.play("blink")
		get_tree().create_timer(1).timeout.connect(end_hurt)
func end_hurt():
	_hurt = false
	$AnimationPlayer.stop()
func die():
	if _state == State.Dashing:
		return
	if _hurt: 
		return
	collision_mask = 0
	hearts_update.emit(0)
	restart.emit()
	_state = State.Dying
	$AnimationPlayer.play("death")
	get_tree().create_timer(1).timeout.connect(start_level)
func heal() -> bool:
	if _health == 3: 
		return false
	_health += 1
	hearts_update.emit(_health)
	return true

## WALLS
func on_left_arm_enter(_body: Node2D):
	_left_wall = true
	if _state == State.Rising or _state == State.Midair or _state == State.Falling or _state == State.Fastfalling:
		if Input.is_action_pressed("jump"):
			wall_jump()
		else:
			_state = State.Walling
func on_left_arm_exit(_body: Node2D):
	_left_wall = false
	if _state == State.Walling:
		_state = State.Midair
func on_right_arm_enter(_body: Node2D):
	_right_wall = true
	if _state == State.Rising or _state == State.Midair or _state == State.Falling or _state == State.Fastfalling:
		if Input.is_action_pressed("jump"):
			wall_jump()
		else:
			_state = State.Walling
func on_right_arm_exit(_body: Node2D):
	_right_wall = false
	if _state == State.Walling:
		_state = State.Midair
	
func wall_jump():
	if _left_wall and _right_wall:
		velocity.y = - jump_velocity_max * wall_velocity_reduction
	elif _left_wall: 
		velocity = Vector2(-1, -2).normalized() * jump_velocity_max * wall_velocity_reduction
	elif _right_wall:
		velocity = Vector2(1, -2).normalized() * jump_velocity_max * wall_velocity_reduction
	_state = State.Rising


## CUSTOM MOVE_AND_SLIDE
func move():
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var c = get_slide_collision(i)
		if c.get_collider().collision_layer & 32:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_strength)

## CHECKPOINT 
func checkpoint(pos):
	if pack == null:
		print("Failed to checkpoint. No packed scene referenced")
		return
	change_checkpoint.emit()
	position += pack.position - pos
	camera.position += pack.position - pos
	pack.position = pos


## DASH 
func start_dash():
	_state = State.Dashing
	dashTimer.start()
	get_tree().create_timer(dash_length).timeout.connect(end_dash)
func end_dash():
	if _left_wall or _right_wall:
		_state = State.Walling
	else:
		_state = State.Falling
func on_dash_ready():
	if _buffer == Action.Dash:
		start_dash()
		_buffer = Action.None


## PROCESSES 
func _process(_delta: float) -> void:
	## DASH TIMER UPDATE
	dash_time_update.emit((1-dashTimer.time_left/ dash_time)*100)
	
	## GROUND UPDATE
	if is_on_floor():
		_last_time_on_ground = Time.get_ticks_msec()
	
	## STATE CHECK
	if _state == State.Dying or _state == State.Dashing:
		return 
	_state = update_states()
	
	
	## FAST FALL
	# fast fall
	if Input.is_action_just_pressed("down"):
		_state = State.Fastfalling
		
	
	## JUMP
	# begin jump 
	if Input.is_action_just_pressed("jump"):
		_begin_jump_time = Time.get_ticks_msec()
		if _state == State.Standing:
			_state = State.Jumping
		elif _state == State.Crouching:
			$AnimationPlayer.play("uncrouch")
			_state = State.Jumping
		elif _state == State.Walling:
			wall_jump()
		else:
			_buffer = Action.Jump
			$Buffer.start()
	if _buffer == Action.Jump:
		if _state == State.Standing or _state == State.Crouching:
			if _state == State.Crouching:
				$AnimationPlayer.play("uncrouch")
			if _end_jump_time < 0:
				_buffer = Action.None
				_state = State.Jumping
			else:
				_buffer = Action.None
				velocity.y = -lerpf(jump_velocity_min, jump_velocity_max, (_end_jump_time - _begin_jump_time)/allowed_jumping_time)
				if _left_wall or _right_wall:
					_state = State.Walling
				else:
					_state = State.Rising
				_end_jump_time = -1
		elif _state == State.Walling:
			_buffer = Action.None
			wall_jump()
	# end jump
	if _state == State.Jumping and (Input.is_action_just_released("jump") or Time.get_ticks_msec() > _begin_jump_time + allowed_jumping_time):
		if _left_wall or _right_wall:
			_state = State.Walling
		else:
			_state = State.Rising
	if  _buffer == Action.Jump and _end_jump_time < 0 and (Input.is_action_just_released("jump") or Time.get_ticks_msec() > _begin_jump_time + allowed_jumping_time):
		_end_jump_time = Time.get_ticks_msec()
	
	
	## DASH
	if Input.is_action_just_pressed("dash"):
		if dashTimer.time_left == 0:
			start_dash()
		else:
			_buffer = Action.Dash
			$Buffer.start()

func _physics_process(delta: float) -> void:
	
	## DYING
	if _state == State.Dying:
		return
		
	## GET SQUISHED
	if is_on_ceiling() and is_on_ground():
		die()
	
	## DASHING
	if _state == State.Dashing:
		velocity = Vector2(_direction * dash_speed, 0)
		move()
		return
	
	## JUMPING
	if _state == State.Jumping:
		velocity.y = -lerpf(jump_velocity_min, jump_velocity_max, (Time.get_ticks_msec() - _begin_jump_time)/allowed_jumping_time)
	
	## GRAVITY 
	if _state == State.Rising or _state == State.Falling or _state == State.Jumping:
		velocity.y += gravity * delta
	elif _state == State.Midair:
		velocity.y += lerp(midair_gravity, gravity, abs(velocity.y) / (_last_jump_velocity * midair_limit)) * delta
	elif _state == State.Walling:
		if velocity.y < 0:
			velocity.y += gravity * delta * 2
		else:
			velocity.y += wall_gravity * delta
	elif _state == State.Fastfalling:
		if velocity.y < 0 or abs(velocity.y) < _last_jump_velocity * midair_limit:
			velocity.y += fast_gravity * delta * 5
		else:
			velocity.y += fast_gravity * delta
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed		
			
	## LATERAL MOVEMENT
	var direction := Input.get_axis("left", "right")
	var _strength = strength if _state == State.Standing or _state == State.Walling or _state == State.Crouching else midair_strength
	if direction:
		velocity.x += direction * delta * _strength
		_direction = sign(direction)
	else:
		velocity.x -= sign(velocity.x) * delta * _strength / 2
		if abs(velocity.x) < zero_velocity_margin:
			velocity.x = 0
	if _state == State.Crouching and abs(velocity.x) > crouch_max_speed:
		velocity.x = sign(velocity.x) * crouch_max_speed
	elif abs(velocity.x) > max_speed:
		velocity.x = sign(velocity.x) * max_speed

	move()


## STATES 
func update_states():
	if _state == State.Jumping or _state == State.Dashing or _state == State.Dying:
		return _state
	if _state == State.Standing and is_on_ground():
		_last_jump_velocity = jump_velocity_max
		if Input.is_action_pressed("down"):
			$AnimationPlayer.play("crouch")
			return State.Crouching
		return _state
	if _state == State.Crouching and is_on_ground(): 
		_last_jump_velocity = jump_velocity_max
		if Input.is_action_pressed("down"):
			return _state
		$AnimationPlayer.play("uncrouch")
		return State.Standing
	if is_on_floor():
		_last_jump_velocity = jump_velocity_max
		if Input.is_action_pressed("jump"):
			_begin_jump_time = Time.get_ticks_msec()
			return State.Jumping
		elif Input.is_action_pressed("down"):
			$AnimationPlayer.play("crouch")
			return State.Crouching
		return State.Standing
	if _state == State.Crouching:
		$AnimationPlayer.play("uncrouch")
	if _state == State.Walling or _state == State.Fastfalling:
		return _state
	if abs(velocity.y) < _last_jump_velocity * midair_limit:
		return State.Midair
	if velocity.y > 0:
		return State.Falling
	if velocity.y < 0:
		return State.Rising
	return State.Fastfalling
