extends StaticBody2D

@export var lethal: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lethal: 
		make_lethal()

func make_lethal():
	$Sprite2D.modulate = Color(1, 40.0/255, 0)
	collision_layer = 8
