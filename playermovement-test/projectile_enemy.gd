extends CharacterBody2D

@export var speed: float = 50.0
@export var min_turn_time: float = 2.0
@export var max_turn_time: float = 5.0
@export var min_distance: float = 100.0  # Minimum distance to maintain from player
@export var push_speed: float = 25.0  # Slower speed for moving away from player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spell_spawn: Marker2D = $SpellSpawn  # Marker positioned above the enemy's head
@onready var detection_area: Area2D = $DetectionArea  # Area2D for player detection
@onready var hitbox: Area2D = $Hitbox  # Area2D for hit detection
var spell_scene: PackedScene = preload("res://enemy_projectile.tscn")

var direction: int = 1  # 1 for right, -1 for left
var player: Node2D = null
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false  # Track if attack animation is playing
var is_hit: bool = false  # Track if hit animation is playing

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
	attack_timer.one_shot = true

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)

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
		if not attack_timer.time_left > 0:
			attack()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		if not is_attacking and not is_hit and animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		start_turn_timer()

func attack() -> void:
	is_attacking = true
	animated_sprite.play("attack")
	
	var spell = spell_scene.instantiate()
	get_parent().add_child(spell)
	spell.global_position = spell_spawn.global_position
	
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if player != null and not is_attacking and not is_hit:
		attack()

func play_hit_animation() -> void:
	if not is_hit:  # Prevent re-triggering if already hit
		is_hit = true
		animated_sprite.play("hit")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackDetector" and area.get_parent().is_in_group("Player"):
		play_hit_animation()

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
		if player != null and not is_hit:
			animated_sprite.play("idle")
		elif not is_hit:
			animated_sprite.play("walk")
	elif animated_sprite.animation == "hit":
		is_hit = false
		if player != null and not is_attacking:
			animated_sprite.play("idle")
		elif not is_attacking:
			animated_sprite.play("walk")

func _physics_process(delta: float) -> void:
	if player == null:
		# Patrol mode
		velocity.x = direction * speed
		if animated_sprite.animation != "walk" and not is_attacking and not is_hit:
			animated_sprite.play("walk")
	else:
		# Attack mode: Face player and maintain distance
		var to_player = player.global_position - global_position
		direction = sign(to_player.x)
		if direction == 0:
			direction = 1
		update_facing()

		var dist = to_player.length()
		if dist < min_distance:
			# Move away smoothly
			var push_factor = (min_distance - dist) / min_distance
			velocity.x = -direction * push_speed * push_factor
		else:
			velocity.x = 0
		
		if not is_attacking and not is_hit and animated_sprite.animation != "idle" and animated_sprite.animation != "attack":
			animated_sprite.play("idle")

	velocity.y += gravity * delta

	move_and_slide()
