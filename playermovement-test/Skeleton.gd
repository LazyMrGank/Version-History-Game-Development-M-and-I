extends CharacterBody2D

class_name SkeletonEnemy

# Movement variables
var is_moving_left: bool = true
@export var speed: float = 10.0
@export var gravity: float = 900.0
var dir: Vector2 = Vector2.RIGHT  # Default direction
var is_attacking: bool = false
var is_hit: bool = false
var health: int = 4
var player: Node2D = null
var chase_speed: float = 48.0
# Nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Start with walk animation
	animated_sprite.play("Walk")
	# Start direction timer
	$DirectionTimer.timeout.connect(_on_direction_timer_timeout)

func edge_detection():
	if not $EdgeDetector.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x

func _physics_process(delta: float) -> void:
	# Apply gravity for platformer
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	# Handle random movement
	velocity.x = dir.x * speed
	handle_animation()
	
	move_and_slide()

func handle_animation() -> void:
	# Update sprite direction based on movement
	if dir.x == -1:
		animated_sprite.flip_h = true
	elif dir.x == 1:
		animated_sprite.flip_h = false
	animated_sprite.play("Walk")

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	dir = choose([Vector2.RIGHT, Vector2.LEFT])

func choose(array):
	array.shuffle()
	return array.front()


func _on_skeleton_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and is_attacking:
		if body.has_method("play_hit_animation"):
			body.play_hit_animation()
			print("Enemy hit player: ", body.name)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_attacking and not is_hit and health > 0:
		is_attacking = true
		$AnimationPlayer.play("Attack")
		$PlayerDetector.monitoring = true

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and is_attacking and not is_hit and health > 0:
		is_attacking = false
		$AnimationPlayer.play("Walk")
		$PlayerDetector.monitoring = false
