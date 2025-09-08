extends CharacterBody2D

const speed = 10
var is_bat_chase: bool = true  # Set to true to enable chasing
var player: Node  # Reference to the player node

func _ready():
	# Find the player node (adjust the path or method as needed)
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		print("Error: Player node not found!")
		is_bat_chase = false  # Disable chasing if no player is found

func _process(delta):
	move(delta)
	handle_animation()

func move(delta):
	if is_bat_chase and player != null:
		# Calculate direction to the player
		var direction = (player.global_position - global_position).normalized()
		# Set velocity to move toward the player
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO  # Stop moving if not chasing or no player
	move_and_slide()

func handle_animation():
	var animated_sprite = $AnimatedSprite2D
	animated_sprite.play("Fly")
	if player != null and is_bat_chase:
		# Flip sprite based on player's position
		if player.global_position.x < global_position.x:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
