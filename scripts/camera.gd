extends Node2D

## Zoom of the camera
@export_range(0, 1) var zoom: float = 0.4
## Speed of the camera following the player. Higher values will fell more rigid, but lower values may leave the camera lagging behind the player
@export_range(0, 10) var speed: float = 3
@export var player: Node2D

func _ready() -> void:
	init()

func init():
	$Camera2D.zoom = Vector2.ONE * zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = lerp(position, player.position, min(speed * delta, 1))
