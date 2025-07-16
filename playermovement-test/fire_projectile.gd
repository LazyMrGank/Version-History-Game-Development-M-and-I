extends Node2D

@export var speed: float = 200.0  # Fireball speed (pixels per second)
@export var lifetime: float = 3.0  # Seconds before despawn
var direction: Vector2 = Vector2(1, 0)  # Default: move right

@onready var animated_sprite = $AnimatedSprite2D  # Reference to animation
@onready var collision_area = $Area2D  # For collision detection
var time_alive: float = 0.0

func _ready():
	# Start animation (adjust name based on your AnimatedSprite2D setup)
	if animated_sprite:
		animated_sprite.play("Firebolt")  # Replace "default" with your animation name

func _physics_process(delta):
	# Move fireball
	global_position += direction * speed * delta
	
	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()
	
	# Optional: Rotate sprite to match direction (if needed)
	# animated_sprite.rotation = direction.angle()

func _on_area2d_body_entered(body):
	# Handle collision (e.g., with enemies or walls)
	if body.is_in_group("enemies"):
		# Example: Deal damage to enemy (add your logic here)
		print("Hit enemy:", body.name)
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()
