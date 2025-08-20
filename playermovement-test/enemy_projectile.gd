extends Area2D

# Speed of the projectile after animation
@export var speed: float = 200.0

# Reference to the player
var player: CharacterBody2D
# Movement direction
var direction: Vector2
# State to track if animation is done
var is_animating: bool = true

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
	if not is_animating:
		# Move projectile towards the player
		position += direction * speed * delta
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Handle player hit (e.g., deal damage, destroy projectile)
		queue_free()
