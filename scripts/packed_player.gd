extends Node2D

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

@export_group("Camera")
## Zoom of the camera
@export_range(0, 1) var zoom: float = 0.4
## Speed of the camera following the player. Higher values will fell more rigid, but lower values may leave the camera lagging behind the player
@export_range(0, 10) var speed: float = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_node("Player")
	var camera = get_node("CameraLock")
	
	player.max_speed = max_speed
	player.strength = strength
	player.midair_strength = midair_strength
	player.zero_velocity_margin = zero_velocity_margin
	
	player.gravity = gravity
	player.midair_gravity = midair_gravity
	player.midair_limit = midair_limit
	player.max_fall_speed = max_fall_speed
	player.wall_gravity = wall_gravity
	player.wall_velocity_reduction = wall_velocity_reduction
	
	player.crouch_max_speed = crouch_max_speed
	player.fast_gravity = fast_gravity
	player.dash_time = dash_time
	player.dash_speed = dash_speed
	player.dash_length = dash_length
	
	player.jump_velocity_min = jump_velocity_min
	player.jump_velocity_max = jump_velocity_max
	player.allowed_jumping_time = allowed_jumping_time
	
	player.knockback = knockback
	player.push_strength = push_strength
	
	player.buffer_time = buffer_time
	player.ground_approximation = ground_approximation

	camera.zoom = zoom
	camera.speed = speed
	
	player.init()
	camera.init()
