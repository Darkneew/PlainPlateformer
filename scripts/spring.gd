extends StaticBody2D

## Velocity it gives to the object/player it launches
@export var strength := 1500
## Lateral velocity it gives the object/player if any
@export var lateral_strength := 0
## Time the spring takes to go back
@export var time := 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = time

func launch(body: Node2D):
	if body is RigidBody2D:
		body.linear_velocity.y = - strength
	elif body is CharacterBody2D:
		body.velocity.y = - strength
	else:
		return
	$Area2D.collision_mask = 0
	$AnimationPlayer.play("eject")
	$Timer.start()

func go_back():
	$AnimationPlayer.play("goback")
	get_tree().create_timer(0.5).timeout.connect(reset)
	
func reset():
	$Area2D.collision_mask = 33
