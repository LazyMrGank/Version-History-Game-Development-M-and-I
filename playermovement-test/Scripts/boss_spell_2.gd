extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Assume AnimatedSprite2D child node
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Assume AnimationPlayer for collision shape toggle
@onready var stall_timer: Timer = Timer.new()

var has_collided_with_player: bool = false

func _ready() -> void:
	# Set up stall timer
	add_child(stall_timer)
	stall_timer.wait_time = 0.5
	stall_timer.one_shot = true
	stall_timer.timeout.connect(_on_stall_timer_timeout)
	
	# Start with stall animation
	animation_player.play("stall")
	stall_timer.start()
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)

func _on_stall_timer_timeout() -> void:
	# After stall, play activation animation
	animation_player.play("activation")  # Assumes AnimationPlayer has an "activation" animation that toggles CollisionShape2D
	# Wait for animation to finish, then free the node
	await animation_player.animation_finished
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		has_collided_with_player = true
		body.play_hit_animation3()
