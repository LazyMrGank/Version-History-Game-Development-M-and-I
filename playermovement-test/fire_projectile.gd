extends Node2D

@onready var area_2d = $Area2D
@onready var animated_sprite = $AnimatedSprite2D

var speed = 8.0
var direction = 1.0  # 1 for right, -1 for left
var is_exploding = false

func _ready():
	animated_sprite.play("Firebolt")
	area_2d.connect("body_entered", _on_body_entered)

func _physics_process(delta):
	if not is_exploding:
		position.x += speed * direction

func _on_body_entered(body):
	if is_exploding:
		return
	if body is TileMap or body.get_collision_layer_value(2):  # Layer 2 for enemies
		is_exploding = true
		animated_sprite.play("Explosion")
		set_physics_process(false)  # Stop movement
		await animated_sprite.animation_finished
		queue_free()
