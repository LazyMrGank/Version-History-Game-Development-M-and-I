extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Play the "Death" animation when the node is ready
	animated_sprite.play("Death")
