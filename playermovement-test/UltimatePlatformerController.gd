extends CharacterBody2D
#Make cooldown for player
@onready var fireball_timer = $FireballTimer
@onready var hit_detector = $HitDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer = $CoyoteTime
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_height_timer = $JumpHeightTimer
@onready var attack_cooldown_timer = $AttackCooldownTimer
var fireball_scene = preload("res://Fireball.tscn")
var can_shoot = true
var can_attack = true
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var deceleration: float = 4000.0
@export var jump_velocity: float = 300.0
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.2
@export var attack_duration: float = 0.5
@export var hit_duration: float = 0.5
const jump_power = -300.0
const wall_jump_pushback = 200
const wall_slide_gravity = 100
var is_wall_sliding = false
var can_coyote_jump = false
var jump_buffered = false
const jump_height: float = -180
const max_speed: float = 60
const friction: float = 10

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 0.0
var last_direction: float = 1.0  # Default facing right
var is_dashing: bool = false
var dash_timer: float = 0.0
var is_attacking: bool = false
var attack_timer: float = 0.0
var is_hit: bool = false
var hit_timer: float = 0.0
var jump_count = 0
var knockback_velocity = Vector2.ZERO
var knockback_friction = 500.0

@export var max_health: float = 100.0  
@export var health: float = 100.0  # Current health
@export var max_mana: float = 100.0  
@export var mana: float = 100.0  # Current mana
@export var mana_drain_rate: float = 15.0  # Mana decrease per second when holding C
@export var health_gain_rate: float = 10.0  # Health increase per second after 2s hold

@onready var health_bar1 = $HealthBar1 
@onready var health_bar2 = $HealthBar2 
@onready var health_bar3 = $HealthBar3
@onready var health_bar4 = $HealthBar4 
@onready var mana_bar1 = $Manabar1 
@onready var mana_bar2 = $Manabar2  

var is_holding_c: bool = false  # Tracks if charge key is held
var c_hold_time: float = 0.0  # Duration C has been held
var is_healing: bool = false  # Tracks if healing is active (after 2s)
var is_holding_d: bool = false  # Tracks if D key is held

func _ready():
	fireball_timer.wait_time = 3.0
	fireball_timer.one_shot = true
	fireball_timer.connect("timeout", _on_fireball_timer_timeout)
	attack_cooldown_timer.wait_time = 1.0
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.connect("timeout", _on_attack_cooldown_timer_timeout)
	hit_detector.body_entered.connect(_on_hit_detector_body_entered)
	health_bar1.min_value = 0
	health_bar1.max_value = 30
	health_bar2.min_value = 30
	health_bar2.max_value = 50
	health_bar3.min_value = 50
	health_bar3.max_value = 80
	health_bar4.min_value = 80
	health_bar4.max_value = 100
	# Initialize mana bar ranges
	mana_bar1.min_value = 0
	mana_bar1.max_value = 50
	mana_bar2.min_value = 50
	mana_bar2.max_value = 100
	update_bars()  # Initialize bars

func _physics_process(delta: float) -> void:
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	
	if Input.is_action_just_pressed("Fireball") and can_shoot:
		shoot_fireball()
	var was_on_floor = is_on_floor()
	# Handle timers
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
	
	if is_hit:
		hit_timer -= delta
		if hit_timer <= 0:
			is_hit = false
	
	# Handle input and movement
	if not is_dashing and not is_hit:
		if not is_on_floor() && (can_coyote_jump == false):
			velocity.y += gravity * delta
			if velocity.y > 500:
				velocity.y = 500
		else:
			jump_count = 0
		if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
			velocity.y = -jump_velocity
			jump_height_timer.start()
			jump()
		if Input.is_action_just_pressed("jump") and jump_count < 2:
			jump_count += 1
			velocity.y = -jump_velocity
				
		if Input.is_action_just_pressed("dash") and not is_on_floor() and not is_dashing and not is_attacking:
			is_dashing = true
			dash_timer = dash_duration
			velocity.y = 0
			velocity.x = last_direction * dash_speed
		
		if Input.is_action_just_pressed("attack") and is_on_floor() and not is_dashing and can_attack:
			is_attacking = true
			attack_timer = attack_duration
			can_attack = false
			attack_cooldown_timer.start()
			if abs(velocity.x) < 10:
				velocity.x = 0
		
		if not is_attacking and not is_dashing:
			direction = Input.get_axis("move_left", "move_right")
		if not is_dashing:
			if direction != 0 and not is_attacking:
				last_direction = direction
				velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	else:
		if is_hit:
			velocity.x = 0
	sprite.scale.x = last_direction
	hit_detector.position.x = abs(hit_detector.position.x) * last_direction
	
	update_animations()

	jump()
	move_and_slide()
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()

	if !was_on_floor && is_on_floor():
		if jump_buffered:
			jump_buffered = false
			print("buffered jump")
			jump()
	wall_slide(delta)

func apply_knockback(knockback):
	knockback_velocity = knockback

func _on_coyote_time_timeout() -> void:
	can_coyote_jump = false

func _input(event):
	if event.is_action_released("jump"):
		if velocity.y < 0.0:
			velocity.y *= 0.5

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false
	print("Jump buffered false")

func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("jump"):
		if velocity.y < -100:
			velocity.y = 0
			print("Cow")
	else:
		print("high jump")

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true

func update_animations() -> void:
	if is_hit:
		animation_player.play("hit")
	elif is_attacking and is_on_floor():
		animation_player.play("attack")
	elif is_dashing:
		animation_player.play("dash")
	elif not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		else:
			animation_player.play("falling")
	elif abs(velocity.x) > 10:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_wall() and Input.is_action_pressed("move_right"):
			velocity.y = jump_power
			velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("move_left"):
			velocity.y = jump_power
		if is_on_floor() || can_coyote_jump:
			if can_coyote_jump:
				velocity.y = jump_velocity
				can_coyote_jump = false
				print("coyote")
		else:
			if !jump_buffered:
				jump_buffered = true
				jump_buffer_timer.start()
				print("Jump buffered true")

func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			is_wall_sliding = true
		else: 
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)

func shoot_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.position = position + Vector2(20 * last_direction, 0)
	fireball.direction = last_direction
	get_tree().current_scene.add_child(fireball)
	can_shoot = false
	fireball_timer.start()

func _on_fireball_timer_timeout() -> void:
	can_shoot = true

func _on_hit_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and is_attacking:
		print("Hit enemy: ", body.name)
		body.play_hit_animation()
		change_mana(+10)

func play_hit_animation():
	if animation_player.has_animation("hit") and not is_hit and not is_dashing:
		is_hit = true
		hit_timer = hit_duration
		velocity.x = 0
		change_health(-10)
	else:
		print("Error: 'hit' animation not found, already playing, or dashing")

func play_hit_animation2():
	if animation_player.has_animation("hit") and not is_hit and not is_dashing:
		is_hit = true
		hit_timer = hit_duration
		velocity.x = 0
		change_health(-20)
	else:
		print("Error: 'hit' animation not found, already playing, or dashing")
		
func play_hit_animatiom3():
	if animation_player.has_animation("hit") and not is_hit and not is_dashing:
		is_hit = true
		hit_timer = hit_duration
		velocity.x = 0
		change_health(-30)
	else:
		print("Error: 'hit' animation not found, already playing, or dashing")

func _process(delta):
	# Charges mana
	if Input.is_action_just_pressed("Charge"):
		is_holding_c = true
		c_hold_time = 0.0
		is_healing = false
	if Input.is_action_just_released("Charge"):
		is_holding_c = false
		is_healing = false
		c_hold_time = 0.0
	if is_holding_c and health < max_health:
		c_hold_time += delta
		
		mana = clamp(mana - mana_drain_rate * delta, 0, max_mana)
		
		if c_hold_time >= 1.5 and mana > 0:
			is_healing = true
			health = clamp(health + health_gain_rate * delta, 0, max_health)
	
	# Handle D key input (health drain for testing)
	if Input.is_action_just_pressed("Fireball"): 
		change_mana(-10)
		change_health(-10)
	update_bars()

func update_bars():
	# Update health bars
	health_bar1.value = clamp(health, health_bar1.min_value, health_bar1.max_value)
	health_bar2.value = clamp(health, health_bar2.min_value, health_bar2.max_value) if health > health_bar2.min_value else health_bar2.min_value
	health_bar3.value = clamp(health, health_bar3.min_value, health_bar3.max_value) if health > health_bar3.min_value else health_bar3.min_value
	health_bar4.value = clamp(health, health_bar4.min_value, health_bar4.max_value) if health > health_bar4.min_value else health_bar4.min_value
	# Update mana bars
	mana_bar1.value = clamp(mana, mana_bar1.min_value, mana_bar1.max_value)
	mana_bar2.value = clamp(mana, mana_bar2.min_value, mana_bar2.max_value) if mana > mana_bar2.min_value else mana_bar2.min_value
	# Changes mana and health bars visually
func change_health(amount: float):
	health = clamp(health + amount, 0, max_health)
	update_bars()

func change_mana(amount: float):
	mana = clamp(mana + amount, 0, max_mana)
	update_bars()
