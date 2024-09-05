extends RigidBody2D

@export var size: float = 1

func kill(_body: Node2D):
	queue_free()

func _ready() -> void:
	$Area2D.scale = Vector2.ONE * size
	$CollisionShape2D.scale = Vector2.ONE * size
	$Sprite2D.scale = Vector2(0.144, 0.3) * size
	mass = size 
