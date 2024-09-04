extends CanvasLayer

const hearts := [preload("res://ressources/coeur_1.png"), preload("res://ressources/coeur_2.png"), preload("res://ressources/coeur_3.png")]

func hearts_update(nb: int):
	if nb == 0:
		$Hearts.texture = null
	else:
		$Hearts.texture = hearts[nb-1]
