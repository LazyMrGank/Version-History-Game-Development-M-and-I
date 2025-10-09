extends CharacterBody2D

@export var speed: float = 50.0
@export var min_turn_time: float = 2.0
@export var max_turn_time: float = 5.0
@export var max_health: int = 4  # Number of hits before death
@export var retreat_speed: float = 50.0  # Speed for retreating from player
@export var retreat_duration: float = 1.0  # Duration of retreat phase
@export var min_idle_time: float = 1.0  # Min wait time for idle phase
@export var max_idle_time: float = 3.0  # Max wait time for idle phase

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spell_spawn: Marker2D = $SpellSpawn  # Marker positioned above the enemy's head
@onready var detection_area: Area2D = $DetectionArea  # Area2D for player detection
@onready var hitbox: Area2D = $Hitbox  # Area2D for hit detection
var spell_scene: PackedScene = preload("res://Scenes/enemy_projectile.tscn")

var direction: int = 1  # 1 for right, -1 for left
var player: Node2D = null
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false  # Track if attack animation is playing
var is_hit: bool = false  # Track if hit animation is playing
var is_dead: bool = false  # Track if death animation is playing
var health: int

enum State { SHOOT, RETREAT, IDLE }
var current_state: State = State.IDLE  # Start in IDLE to avoid premature attack
var retreat_timer: Timer
var idle_timer: Timer
var turn_timer: Timer
var attack_timer: Timer

func _ready() -> void:
	health = max_health
	turn_timer = Timer.new()
	add_child(turn_timer)
	turn_timer.timeout.connect(_on_turn_timer_timeout)
	start_turn_timer()

	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.wait_time = 7.0
	attack_timer.one_shot = true

	retreat_timer = Timer.new()
	add_child(retreat_timer)
	retreat_timer.timeout.connect(_on_retreat_timer_timeout)
	retreat_timer.one_shot = true

	idle_timer = Timer.new()
	add_child(idle_timer)
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	idle_timer.one_shot = true

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)

	animated_sprite.play("walk")

func start_turn_timer() -> void:
	if not is_dead:
		turn_timer.wait_time = randf_range(min_turn_time, max_turn_time)
		turn_timer.start()

func _on_turn_timer_timeout() -> void:
	direction = -direction
	update_facing()
	start_turn_timer()

func update_facing() -> void:
	animated_sprite.flip_h = (direction < 0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_dead:
		player = body
		turn_timer.stop()
		current_state = State.SHOOT
		if not attack_timer.time_left > 0:
			attack()
		else:
			animated_sprite.play("idle")  # Wait in idle if attack is on cooldown
		print("Player entered, state: ", State.keys()[current_state])

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		current_state = State.IDLE
		if not is_attacking and not is_hit and not is_dead:
			animated_sprite.play("walk")
		start_turn_timer()
		retreat_timer.stop()
		idle_timer.stop()
		print("Player exited, resuming patrol")

func attack() -> void:
	if not is_dead:
		is_attacking = true
		animated_sprite.play("attack")
		var spell = spell_scene.instantiate()
		get_parent().add_child(spell)
		spell.global_position = spell_spawn.global_position
		attack_timer.start()
		print("Attack triggered, cooldown started")

func _on_attack_timer_timeout() -> void:
	if player != null and not is_attacking and not is_hit and not is_dead and current_state == State.SHOOT:
		attack()
	else:
		print("Attack timer done, but no attack (state: ", State.keys()[current_state], ")")

func play_hit_animation() -> void:
	if not is_hit and not is_dead:
		health -= 1
		if health <= 0:
			is_dead = true
			animated_sprite.play("death")
		else:
			is_hit = true
			animated_sprite.play("hit")
		print("Hit, health: ", health)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackDetector" and area.get_parent().is_in_group("Player"):
		play_hit_animation()

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
		if player != null and not is_hit and not is_dead:
			current_state = State.RETREAT
			retreat_timer.start(retreat_duration)
			animated_sprite.play("walk")
			print("Attack finished, switching to RETREAT")
		elif not is_hit and not is_dead:
			animated_sprite.play("walk")
			current_state = State.IDLE
			print("Attack finished, no player, switching to IDLE")
	elif animated_sprite.animation == "hit":
		is_hit = false
		if player != null and not is_attacking and not is_dead:
			if current_state == State.RETREAT:
				animated_sprite.play("walk")
			else:
				animated_sprite.play("idle")
			print("Hit finished, state: ", State.keys()[current_state])
		elif not is_attacking and not is_dead:
			animated_sprite.play("walk")
			current_state = State.IDLE
			print("Hit finished, no player, switching to IDLE")
	elif animated_sprite.animation == "death":
		queue_free()
		print("Death animation finished, enemy removed")

func _on_retreat_timer_timeout() -> void:
	if player != null and not is_dead:
		current_state = State.IDLE
		idle_timer.start(randf_range(min_idle_time, max_idle_time))
		animated_sprite.play("idle")
		print("Retreat finished, switching to IDLE, idle time: ", idle_timer.wait_time)
	else:
		print("Retreat timer done, but no player")

func _on_idle_timer_timeout() -> void:
	if player != null and not is_dead:
		current_state = State.SHOOT
		if not is_attacking and not is_hit:
			if not attack_timer.time_left > 0:
				attack()
			else:
				animated_sprite.play("idle")  # Stay idle if attack is on cooldown
			print("Idle finished, switching to SHOOT")
	else:
		print("Idle timer done, but no player")

func _physics_process(delta: float) -> void:
	if is_dead or is_hit or is_attacking:
		velocity.x = 0
		return
	
	if player == null:
		# Patrol mode
		velocity.x = direction * speed
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		current_state = State.IDLE
	else:
		# Attack mode: Face player and handle state cycle
		var to_player = player.global_position - global_position
		direction = sign(to_player.x)
		if direction == 0:
			direction = 1
		update_facing()

		if current_state == State.RETREAT:
			velocity.x = -direction * retreat_speed
			if animated_sprite.animation != "walk":
				animated_sprite.play("walk")
		else:
			velocity.x = 0
			if current_state == State.IDLE and animated_sprite.animation != "idle":
				animated_sprite.play("idle")
			elif current_state == State.SHOOT and animated_sprite.animation != "attack" and not is_attacking:
				animated_sprite.play("idle")  # Idle while waiting for attack cooldown

	velocity.y += gravity * delta
	move_and_slide()
