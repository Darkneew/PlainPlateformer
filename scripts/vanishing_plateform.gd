extends StaticBody2D

## Time before the plateform reappears
@export var respawn_time := 3.0
## Time it takes for the plateform to vanish
@export var vanishing_time := 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = respawn_time
	$AnimationPlayer.speed_scale = 1/vanishing_time

func start_vanish(_body: Node2D):
	$AnimationPlayer.play("vanish")
	$Area2D.collision_mask = 0
	get_tree().create_timer(vanishing_time).timeout.connect(vanish)

func vanish():
	collision_layer = 0
	$Timer.start()
	
	
func reappear():
	$AnimationPlayer.play("RESET")
	$Area2D.collision_mask = 1
	collision_layer = 18
