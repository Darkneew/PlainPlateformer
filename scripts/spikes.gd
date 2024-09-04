extends Node2D

@export var lethal: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lethal:
		for i in range(get_child_count()):
			get_child(i).make_lethal()
