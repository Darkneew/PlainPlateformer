extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("float")
	
func on_pickup(body: Node2D):
	var healed = body.heal()
	if not healed:
		return
	collision_mask = 0
	$AnimationPlayer.play("pickup")
	body.restart.connect(reset)
	get_tree().create_timer(0.6).timeout.connect(pickedup)

func pickedup():
	$Sprite2D.visible = false
	
func reset():
	collision_mask = 1
	$AnimationPlayer.play("float")
	$Sprite2D.visible = true
