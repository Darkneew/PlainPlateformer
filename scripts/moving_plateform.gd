extends CharacterBody2D

## Time needed to go to the target
@export var time_outward := 4.0
## Time needed to get back
@export var time_return := 4.0
## Target to go to
@export var target: Node2D

@onready var timer: Timer = get_node("Timer")

var _start_pos: Vector2
var _end_pos: Vector2
var _outward: bool
var _speed_outward: float
var _dist: float
var _speed_return: float

func _ready() -> void:
	if target == null:
		print("A moving object has no target")
	_start_pos = position
	_end_pos = target.position
	_dist = (_end_pos - _start_pos).length()
	_speed_outward = _dist / time_outward
	_speed_return = _dist / time_return
	next_journey()
	
	
func next_journey():
	if _outward:
		_outward = false
		timer.wait_time = time_return
		timer.start()
	else:
		_outward = true
		timer.wait_time = time_outward
		timer.start()

func _physics_process(_delta: float) -> void:
	var coef = sin(timer.time_left/timer.wait_time * PI) / 2 * PI
	if _outward:
		velocity = (_end_pos - position).normalized() * _speed_outward * coef
	else:
		velocity = (_start_pos - position).normalized() * _speed_return * coef
	move_and_slide()
