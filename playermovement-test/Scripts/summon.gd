extends CharacterBody2D

@export var speed: float = 100.0  # Speed at which the enemy follows the player

var player: Node2D  # Reference to the player
var is_attacking: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	# Find the player node in the "player" group
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]  # Assume the first node in the group is the player
	else:
		print("Warning: No player found in group 'player'!")
	
	# Connect Area2D signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	# Start with fly animation
	animated_sprite.play("fly")

func _physics_process(delta: float) -> void:
	if is_attacking or player == null:
		velocity = Vector2.ZERO  # Stand still during attack
		return
	
	# Calculate direction to player
	var direction: Vector2 = (player.global_position - global_position).normalized()
	
	# Move towards player
	velocity = direction * speed
	move_and_slide()
	
	# Flip sprite based on direction (optional, for left/right facing)
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_attacking = true
		animated_sprite.play("attack")
		# Optional: Add attack logic here, like dealing damage via a timer or signal

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_attacking = false
		animated_sprite.play("fly")
