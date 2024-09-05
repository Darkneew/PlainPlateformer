extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("rotate")

func on_entered(body: Node2D):
	body.on_win()	
