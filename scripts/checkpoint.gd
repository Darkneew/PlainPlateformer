extends Area2D

var _body: Node2D

var _reset_immune := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("blink")

func on_entered(body: Node2D):
	body.change_checkpoint.connect(reset_blink)
	_body = body
	$AnimationPlayer.play("check")
	collision_mask = 0
	get_tree().create_timer(1).timeout.connect(blink2)
	_reset_immune = true
	var _pos = position
	_pos.y += 80
	body.checkpoint(_pos)
	
func blink2():
	if $AnimationPlayer.current_animation == "check": 
		$AnimationPlayer.play("blink2")

func reset_blink():
	if _reset_immune:
		_reset_immune = false
		return
	$AnimationPlayer.play("blink")
	collision_mask = 1
	
