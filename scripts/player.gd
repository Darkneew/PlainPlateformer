extends CharacterBody2D

enum State {Standing, Jumping, Rising, Midair, Falling, Dashing, Walling, Fastfalling}
enum Action {None, Dash, Jump}

@export_group("Horizontal Mouvement")
@export var max_speed := 600.0
@export var strength := 3000.0
@export var midair_strength := 1500.0

@export_group("Vertical Movement")
@export var jump_velocity := 1000.0
@export var gravity := 1100.0
@export var midair_gravity := 600.0
@export var fast_gravity := 3000.0
@export var wall_gravity := 100.0
@export_range(0,1) var midair_limit := 0.3
@export var max_fall_speed := 1500.0

var _state: State = State.Fastfalling
var _buffer: Action = Action.None

func _process(delta: float) -> void:
	
	## CONTROLS
	# fast fall
	if Input.is_action_just_pressed("ui_down"):
		_state = State.Fastfalling

func _physics_process(delta: float) -> void:
	_state = update_states()
	
	if _state == State.Dashing:
		return
	
	## GRAVITY 
	if _state == State.Rising or _state == State.Falling or _state == State.Jumping:
		velocity.y += gravity * delta
	elif _state == State.Midair:
		velocity.y += lerp(midair_gravity, gravity, abs(velocity.y) / (jump_velocity * midair_limit)) * delta
	elif _state == State.Walling:
		velocity.y += wall_gravity * delta
	elif _state == State.Fastfalling:
		if velocity.y < 0 or abs(velocity.y) < jump_velocity * midair_limit:
			velocity.y += fast_gravity * delta * 5
		else:
			velocity.y += fast_gravity * delta
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed
	
	## MOVEMENT 
	# jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = - jump_velocity
		# change to measure time pressed to change midair_limit and jump_velocity
	# lateral movement
	var direction := Input.get_axis("ui_left", "ui_right")
	var _strength = strength if _state == State.Standing or _state == State.Walling else midair_strength
	if direction:
		velocity.x += direction * delta * _strength
	else:
		velocity.x -= sign(velocity.x) * delta * _strength / 2
	if abs(velocity.x) > max_speed:
		velocity.x = sign(velocity.x) * max_speed

	move_and_slide()

func update_states():
	if _state == State.Jumping or _state == State.Dashing:
		return _state
	if is_on_floor():
		return State.Standing
	if _state == State.Walling or _state == State.Fastfalling:
		return _state
	if abs(velocity.y) < jump_velocity * midair_limit:
		return State.Midair
	if velocity.y > 0:
		return State.Falling
	if velocity.y < 0:
		return State.Rising
	return State.Fastfalling
