extends Area2D

@export var speed: float = 200.0  # Speed of the fireball in pixels per second
var direction: int = -1  # 1 for right, -1 for left (set this when instantiating)
var velocity: Vector2 = Vector2.ZERO
var is_exploding: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Assume you have an AnimatedSprite2D child node
@onready var explosion_timer: Timer = Timer.new()

func _ready() -> void:
	# Flip sprite if moving left
	if direction == -1:
		animated_sprite.flip_h = true
	
	# Set initial velocity (horizontal only)
	velocity.x = speed * direction
	
	# Play moving animation
	animated_sprite.play("moving")
	
	# Set up the explosion timer
	add_child(explosion_timer)
	explosion_timer.wait_time = 2.0
	explosion_timer.one_shot = true
	explosion_timer.timeout.connect(_on_explosion_timer_timeout)
	explosion_timer.start()
	
	# Connect body entered signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not is_exploding:
		position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if not is_exploding and body.is_in_group("Player"):  # Assuming the player is in a group called "player"
		explode()
		body.play_hit_animation3()

func _on_explosion_timer_timeout() -> void:
	explode()

func explode() -> void:
	if is_exploding:
		return
	is_exploding = true
	velocity = Vector2.ZERO
	animated_sprite.play("explosion")
	# Optionally, disable monitoring to prevent further collisions
	monitoring = false
	monitorable = false
	# Wait for animation to finish then free the node
	await animated_sprite.animation_finished
	
	queue_free()
