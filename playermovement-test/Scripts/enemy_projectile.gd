extends Area2D

# Speed of the projectile after animation
@export var speed: float = 150.0

# Reference to the player
var player: Node2D
# Movement direction
var direction: Vector2
# State to track if animation is done
var is_animating: bool = true
# State to track if exploding
var is_exploding: bool = false

func _ready():
	# Find the player node in the scene
	player = get_tree().get_first_node_in_group("Player")
	if not player:
		queue_free() # Remove projectile if no player is found
		return
	
	# Play creation animation
	$AnimatedSprite2D.play("creation")
	
	# Start a timer for the 1-second animation
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(_on_animation_finished)

func _on_animation_finished():
	# Animation done, start moving
	is_animating = false
	# Calculate direction towards the player
	direction = (player.global_position - global_position).normalized()
	# Switch to moving animation
	$AnimatedSprite2D.play("moving")

func _physics_process(delta):
	if not is_animating and not is_exploding:
		# Move projectile towards the player
		position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not is_exploding:
			is_exploding = true
			$AnimatedSprite2D.play("hitting") # Play explosion animation
			# Stop movement
			set_physics_process(false)
			# Wait for animation to finish
			body.play_hit_animation2()
			await $AnimatedSprite2D.animation_finished
			print("Hit")
			queue_free()
