extends CharacterBody2D

@export var speed: float = 50.0
@export var min_turn_time: float = 2.0
@export var max_turn_time: float = 5.0
@export var spell_scene: PackedScene
@export var min_distance: float = 50.0  # Minimum distance to maintain from player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spell_spawn: Marker2D = $SpellSpawn  # Marker positioned above the enemy's head
@onready var detection_area: Area2D = $DetectionArea  # Area2D for player detection

var direction: int = 1  # 1 for right, -1 for left
var player: Node2D = null
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var turn_timer: Timer
var attack_timer: Timer

func _ready() -> void:
	turn_timer = Timer.new()
	add_child(turn_timer)
	turn_timer.timeout.connect(_on_turn_timer_timeout)
	start_turn_timer()

	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.wait_time = 7.0
	attack_timer.one_shot = false

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

	# Assume animations: "walk", "attack", "idle" (if no idle, replace with "walk")
	animated_sprite.play("walk")

func start_turn_timer() -> void:
	turn_timer.wait_time = randf_range(min_turn_time, max_turn_time)
	turn_timer.start()

func _on_turn_timer_timeout() -> void:
	direction = -direction
	update_facing()
	start_turn_timer()

func update_facing() -> void:
	animated_sprite.flip_h = (direction < 0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		turn_timer.stop()
		attack()  # Immediate attack on enter
		attack_timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		attack_timer.stop()
		animated_sprite.play("walk")
		start_turn_timer()

func attack() -> void:
	animated_sprite.play("attack")
	
	# Instance the spell scene above the head
	var spell = spell_scene.instantiate()
	get_parent().add_child(spell)
	spell.global_position = spell_spawn.global_position
	# Optionally, connect to animation finished to return to idle
	# animated_sprite.animation_finished.connect(_on_attack_animation_finished, CONNECT_ONE_SHOT)
func _on_attack_timer_timeout() -> void:
	if player != null:
		attack()
# Optional: If you want to return to idle after attack animation
# func _on_attack_animation_finished() -> void:
#     if player != null:
#         animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if player == null:
		# Patrol mode
		velocity.x = direction * speed
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	else:
		# Attack mode: Face player and maintain distance
		var to_player = player.global_position - global_position
		direction = sign(to_player.x)
		if direction == 0:
			direction = 1  # Default to right if directly above/below
		update_facing()

		var dist = to_player.length()
		if dist < min_distance:
			# Move away from player
			velocity.x = -direction * speed
		else:
			# Stay put
			velocity.x = 0
		
		# Play idle if not attacking (assuming attack interrupts and returns)
		if animated_sprite.animation != "attack":
			animated_sprite.play("idle")  # Or "walk" if no idle

	# Apply gravity (for platformer falling if off edges)
	velocity.y += gravity * delta

	move_and_slide()
