extends Node2D

@onready var area_2d = $Area2D
@onready var animated_sprite = $AnimatedSprite2D

var speed = 8.0
var direction = 1.0  # 1 for right, -1 for left
var is_exploding = false

func _ready():
	animated_sprite.play("Firebolt")
	animated_sprite.flip_h = direction < 0
	area_2d.connect("body_entered", _on_body_entered)
	animated_sprite.connect("animation_finished", _on_animation_finished)

func _physics_process(delta):
	if not is_exploding:
		position.x += speed * direction

func _on_body_entered(body):
	if body.is_in_group("enemies") and not is_exploding:
		is_exploding = true
		animated_sprite.play("Explosion")
		# Stop movement
		speed = 0
		# Optionally disable collision to prevent multiple hits
		area_2d.set_deferred("monitoring", false)
		area_2d.set_deferred("monitorable", false)

func _on_animation_finished():
	if is_exploding and animated_sprite.animation == "Explosion":
		queue_free()  # Remove the fireball node after explosion animation
